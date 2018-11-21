package laya.d3.loaders {
	import laya.d3.core.material.Material;
	import laya.d3.graphics.IndexBuffer3D;
	import laya.d3.graphics.VertexBuffer3D;
	import laya.d3.graphics.VertexDeclaration;
	import laya.d3.graphics.VertexElement;
	import laya.d3.graphics.VertexPositionNormalColor;
	import laya.d3.graphics.VertexPositionNormalColorSkin;
	import laya.d3.graphics.VertexPositionNormalColorTexture;
	import laya.d3.graphics.VertexPositionNormalColorTexture0Texture1;
	import laya.d3.graphics.VertexPositionNormalColorTexture0Texture1Skin;
	import laya.d3.graphics.VertexPositionNormalColorTextureSkin;
	import laya.d3.graphics.VertexPositionNormalTexture;
	import laya.d3.graphics.VertexPositionNormalTexture0Texture1;
	import laya.d3.graphics.VertexPositionNormalTexture0Texture1Skin;
	import laya.d3.graphics.VertexPositionNormalTextureSkin;
	import laya.d3.resource.models.Mesh;
	import laya.d3.resource.models.SubMesh;
	import laya.d3.utils.Utils3D;
	import laya.events.Event;
	import laya.net.Loader;
	import laya.net.URL;
	import laya.resource.Resource;
	import laya.utils.Byte;
	import laya.utils.ClassUtils;
	import laya.utils.Handler;
	import laya.webgl.WebGLContext;
	
	/**
	 * @private
	 * <code>LoadModel</code> 类用于模型加载。
	 */
	public class LoadModel {
		/**@private */
		private static var _attrReg:RegExp =/*[STATIC SAFE]*/ new RegExp("(\\w+)|([:,;])", "g");//切割字符串正则
		
		/**@private */
		private var _strings:Array = ['BLOCK', 'DATA', "STRINGS"];//字符串数组
		/**@private */
		private var _materials:Vector.<Material>;
		/**@private */
		private var _fileData:ArrayBuffer;
		/**@private */
		private var _readData:Byte;
		/**@private */
		private var _mesh:Mesh;
		/**@private */
		private var _BLOCK:Object = {count: 0};
		/**@private */
		private var _DATA:Object = {offset: 0, size: 0};
		/**@private */
		private var _STRINGS:Object = {offset: 0, size: 0};
		
		/**@private */
		private var _shaderAttributes:Array;
		
		public function get mesh():Mesh {
			return _mesh;
		}
		
		/**
		 * 创建一个 <code>LoadModel</code> 实例。
		 */
		public function LoadModel(data:ArrayBuffer, mesh:Mesh, materials:Vector.<Material>, url:String) {
			_mesh = mesh;
			_materials = materials;
			_onLoaded(data, url);
		}
		
		/**
		 * @private
		 */
		private function _onLoaded(data:*, url:String):Mesh {
			var preBasePath:String = URL.basePath;
			URL.basePath = URL.getPath(URL.formatURL(url));//此处更换URL路径会影响模型寻找贴图的路径
			
			_fileData = data;
			
			_readData = new Byte(_fileData);
			_readData.pos = 0;
			
			var version:String = _readData.readUTFString();
			
			READ_BLOCK();
			
			for (var i:int = 0; i < _BLOCK.count; i++) {
				var index:int = _readData.getUint16();
				var blockName:String = _strings[index];
				var fn:Function = this["READ_" + blockName];
				if (fn == null) throw new Error("model file err,no this function:" + index + " " + blockName);
				//trace("--------------call:" + "READ_" + blockName);
				if (!fn.call(this)) break;
			}
			
			URL.basePath = preBasePath;
			return _mesh;
		}
		
		public function onError():void {
		}
		
		/**
		 * @private
		 */
		private function _readString():String {
			return _strings[_readData.getUint16()];
		}
		
		public function READ_BLOCK():Boolean {
			var n:int = _readData.getUint16();
			_BLOCK.count = _readData.getUint16();
			return true;
		}
		
		public function READ_DATA():Boolean {
			_DATA.offset = _readData.getUint32();
			_DATA.size = _readData.getUint32();
			return true;
		}
		
		public function READ_STRINGS():Boolean {
			_STRINGS.offset = _readData.getUint16();
			_STRINGS.size = _readData.getUint16();
			var ofs:int = _readData.pos;
			_readData.pos = _STRINGS.offset + _DATA.offset;
			for (var i:int = 0; i < _STRINGS.size; i++) {
				_strings[i] = _readData.readUTFString();
					//trace("string:" + i + "  " + _strings[i]);
			}
			_readData.pos = ofs;
			return true;
		}
		
		public function READ_MATERIAL():Boolean {
			var i:int, n:int;
			var index:int = _readData.getUint16();
			
			var shaderName:String = _readString();
			var url:String = _readString();
			
			if (url !== "null") {
				url = URL.formatURL(url);
				
				var material:Material = Resource.materialCache[url];
				
				if (material) {
					_materials[index] = material;
				} else {
					material = _materials[index] = Resource.materialCache[url] = new Material();
					material.setShaderName(shaderName);
					Material.createFromFile(url, material);
				}
			} else {
				_materials[index] = new Material();
			}
			//trace("MATERIAL:" + index + " " + materialPath);
			return true;
		}
		
		public function READ_MESH():Boolean {
			var name:String = _readString();
			//trace("READ_MESH:" + name);
			return true;
		}
		
		public function READ_SUBMESH():Boolean {
			var className:String = _readString();
			var material:int = _readData.getUint8();
			
			var bufferAttribute:String = _readString();
			_shaderAttributes = bufferAttribute.match(_attrReg);
			
			var ibofs:int = _readData.getUint32();
			var ibsize:int = _readData.getUint32();
			var vbIndicesofs:int = _readData.getUint32();
			var vbIndicessize:int = _readData.getUint32();
			var vbofs:int = _readData.getUint32();
			var vbsize:int = _readData.getUint32();
			var boneDicofs:int = _readData.getUint32();
			var boneDicsize:int = _readData.getUint32();
			var arrayBuffer:ArrayBuffer = _readData.__getBuffer();
			//trace("SUBMESH:ibofs=" + ibofs + "  ibsize=" + ibsize + "  vbofs=" + vbofs + " vbsize=" + vbsize + "  boneDicofs=" + boneDicofs + " boneDicsize=" + boneDicsize + " " + bufferAttribute);
			var submesh:SubMesh = new SubMesh(_mesh);
			
			//_mesh.vb || (_mesh.vb = new Buffer(WebGLContext.ARRAY_BUFFER));
			//submesh.setVBOffset(_mesh.vb.length);
			//_mesh.vb.append(new Uint8Array(arrayBuffer, vbofs + _DATA.offset, vbsize));
			
			submesh.material = material;
			submesh.verticesIndices = new Uint32Array(arrayBuffer.slice(vbIndicesofs + _DATA.offset, vbIndicesofs + _DATA.offset + vbIndicessize));
			
			var vertexDeclaration:VertexDeclaration = _getVertexDeclaration();
			
			var vb:VertexBuffer3D = VertexBuffer3D.create(vertexDeclaration, vbsize / vertexDeclaration.vertexStride, WebGLContext.STATIC_DRAW, true);
			var vbStart:int = vbofs + _DATA.offset;
			var vbArrayBuffer:ArrayBuffer = arrayBuffer.slice(vbStart, vbStart + vbsize);
			vb.setData(new Float32Array(vbArrayBuffer));
			submesh.setVB(vb);
			
			var vertexElements:Array = vb.vertexDeclaration.getVertexElements();
			for (var i:int = 0; i < vertexElements.length; i++)
				submesh._bufferUsage[(vertexElements[i] as VertexElement).elementUsage] = vb;
			
			var ib:IndexBuffer3D = IndexBuffer3D.create(IndexBuffer3D.INDEXTYPE_USHORT, ibsize / 2, WebGLContext.STATIC_DRAW, true);
			var ibStart:int = ibofs + _DATA.offset;
			var ibArrayBuffer:ArrayBuffer = arrayBuffer.slice(ibStart, ibStart + ibsize);
			ib.setData(new Uint16Array(ibArrayBuffer));
			submesh.setIB(ib, ibsize / 2);
			
			var boneDicArrayBuffer:ArrayBuffer = arrayBuffer.slice(boneDicofs + _DATA.offset, boneDicofs + _DATA.offset + boneDicsize);
			submesh._setBoneDic(new Uint8Array(boneDicArrayBuffer));
			
			_mesh.add(submesh);
			
			return true;
		}
		
		public function READ_DATAAREA():Boolean {
			return false;
		}
		
		private function _getVertexDeclaration():VertexDeclaration {
			var position:Boolean, normal:Boolean, color:Boolean, texcoord0:Boolean, texcoord1:Boolean, blendWeight:Boolean, blendIndex:Boolean;
			for (var i:int = 0; i < _shaderAttributes.length; i += 8) {
				switch (_shaderAttributes[i]) {
				case "POSITION": 
					position = true;
					break;
				case "NORMAL": 
					normal = true;
					break;
				case "COLOR": 
					color = true;
					break;
				case "UV": 
					texcoord0 = true;
					break;
				case "UV1": 
					texcoord1 = true;
					break;
				case "BLENDWEIGHT": 
					blendWeight = true;
					break;
				case "BLENDINDICES": 
					blendIndex = true;
					break;
				}
			}
			var vertexDeclaration:VertexDeclaration;
			
			if (position && normal && color && texcoord0 && texcoord1 && blendWeight && blendIndex)
				vertexDeclaration = VertexPositionNormalColorTexture0Texture1Skin.vertexDeclaration;
			else if (position && normal && texcoord0 && texcoord1 && blendWeight && blendIndex)
				vertexDeclaration = VertexPositionNormalTexture0Texture1Skin.vertexDeclaration;
			else if (position && normal && color && texcoord0 && blendWeight && blendIndex)
				vertexDeclaration = VertexPositionNormalColorTextureSkin.vertexDeclaration;
			else if (position && normal && texcoord0 && blendWeight && blendIndex)
				vertexDeclaration = VertexPositionNormalTextureSkin.vertexDeclaration;
			else if (position && normal && color && blendWeight && blendIndex)
				vertexDeclaration = VertexPositionNormalColorSkin.vertexDeclaration;
			else if (position && normal && color && texcoord0 && texcoord1)
				vertexDeclaration = VertexPositionNormalColorTexture0Texture1.vertexDeclaration;
			else if (position && normal && texcoord0 && texcoord1)
				vertexDeclaration = VertexPositionNormalTexture0Texture1.vertexDeclaration;
			else if (position && normal && color && texcoord0)
				vertexDeclaration = VertexPositionNormalColorTexture.vertexDeclaration;
			else if (position && normal && texcoord0)
				vertexDeclaration = VertexPositionNormalTexture.vertexDeclaration;
			else if (position && normal && color)
				vertexDeclaration = VertexPositionNormalColor.vertexDeclaration;
			
			return vertexDeclaration;
		}
	
	}

}
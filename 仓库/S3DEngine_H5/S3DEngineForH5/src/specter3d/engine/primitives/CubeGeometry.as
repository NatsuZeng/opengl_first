package specter3d.engine.primitives
{
	import laya.d3.graphics.VertexElement;
	import laya.d3.graphics.VertexElementFormat;
	
	import specter3d.engine.materials.compilation.ShaderRegisterUsage;
	import specter3d.engine.resources.Geometry3D;
	import specter3d.engine.resources.SubGeometry3D;
	import specter3d.engine.utlis.GeomUtil;
	
	public class CubeGeometry extends Geometry3D
	{
		private var _width : Number;
		private var _height : Number;
		private var _depth : Number;
		private var _tile6 : Boolean;
		
		private var _segmentsW : Number;
		private var _segmentsH : Number;
		private var _segmentsD : Number;
		
		public function CubeGeometry(width : Number = 100, height : Number = 100, depth : Number = 100,
									 segmentsW : uint = 1, segmentsH : uint = 1, segmentsD : uint = 1, tile6 : Boolean = true)
		{
			super();			
			_width = width;
			_height = height;
			_depth = depth;
			_segmentsW = segmentsW;
			_segmentsH = segmentsH;
			_segmentsD = segmentsD;
			_tile6 = tile6;
			buildGeometry();
		}
		
		protected function buildGeometry():void
		{
			var target:SubGeometry3D=new SubGeometry3D();
			var data : Float32Array;
			var indices : Uint16Array;
			
			var tl : uint, tr : uint, bl : uint, br : uint;
			var i : uint, j : uint, inc : uint = 0;
			
			var vidx  :  uint, fidx  :  uint; // indices
			var hw : Number, hh : Number, hd : Number; // halves
			var dw : Number, dh : Number, dd : Number; // deltas
			
			var outer_pos : Number;
			
			var numVerts : uint = 	((_segmentsW + 1) * (_segmentsH + 1) +
				(_segmentsW + 1) * (_segmentsD + 1) +
				(_segmentsH + 1) * (_segmentsD + 1)) * 2;
			
			var stride:uint = 13;
			var skip:uint = stride - 9;
			
			data = new Float32Array(numVerts * stride, true);
			indices = new Uint16Array((_segmentsW*_segmentsH + _segmentsW*_segmentsD + _segmentsH*_segmentsD)*12, true);
//			invalidateUVs();
			
			vidx = 0;
			fidx = 0;
			
			// half cube dimensions
			hw = _width/2;
			hh = _height/2;
			hd = _depth/2;
			
			// Segment dimensions
			dw = _width/_segmentsW;
			dh = _height/_segmentsH;
			dd = _depth/_segmentsD;
			
			for (i = 0; i <= _segmentsW; i++) {
				outer_pos = -hw + i*dw;
				
				for (j = 0; j <= _segmentsH; j++) {
					// front
					data[vidx++] = outer_pos;
					data[vidx++] = -hh + j*dh;
					data[vidx++] = -hd;
					data[vidx++] = 0;
					data[vidx++] = 0;
					data[vidx++] = -1;
					data[vidx++] = 1;
					data[vidx++] = 0;
					data[vidx++] = 0;
					vidx += skip;
					
					// back
					data[vidx++] = outer_pos;
					data[vidx++] = -hh + j*dh;
					data[vidx++] = hd;
					data[vidx++] = 0;
					data[vidx++] = 0;
					data[vidx++] = 1;
					data[vidx++] = -1;
					data[vidx++] = 0;
					data[vidx++] = 0;
					vidx += skip;
					
					if (i && j) {
						tl = 2 * ((i-1) * (_segmentsH + 1) + (j-1));
						tr = 2 * (i * (_segmentsH + 1) + (j-1));
						bl = tl + 2;
						br = tr + 2;
						
						indices[fidx++] = tl;
						indices[fidx++] = bl;
						indices[fidx++] = br;
						indices[fidx++] = tl;
						indices[fidx++] = br;
						indices[fidx++] = tr;
						indices[fidx++] = tr+1;
						indices[fidx++] = br+1;
						indices[fidx++] = bl+1;
						indices[fidx++] = tr+1;
						indices[fidx++] = bl+1;
						indices[fidx++] = tl+1;
					}
				}
			}
			
			inc += 2*(_segmentsW + 1)*(_segmentsH + 1);
			
			for (i = 0; i <= _segmentsW; i++) {
				outer_pos = -hw + i*dw;
				
				for (j = 0; j <= _segmentsD; j++) {
					// top
					data[vidx++] = outer_pos;
					data[vidx++] = hh;
					data[vidx++] = -hd + j*dd;
					data[vidx++] = 0;
					data[vidx++] = 1;
					data[vidx++] = 0;
					data[vidx++] = 1;
					data[vidx++] = 0;
					data[vidx++] = 0;
					vidx += skip;
					
					// bottom
					data[vidx++] = outer_pos;
					data[vidx++] = -hh;
					data[vidx++] = -hd + j*dd;
					data[vidx++] = 0;
					data[vidx++] = -1;
					data[vidx++] = 0;
					data[vidx++] = 1;
					data[vidx++] = 0;
					data[vidx++] = 0;
					vidx += skip;
					
					if (i && j) {
						tl = inc + 2 * ((i-1) * (_segmentsD + 1) + (j-1));
						tr = inc + 2 * (i * (_segmentsD + 1) + (j-1));
						bl = tl + 2;
						br = tr + 2;
						
						indices[fidx++] = tl;
						indices[fidx++] = bl;
						indices[fidx++] = br;
						indices[fidx++] = tl;
						indices[fidx++] = br;
						indices[fidx++] = tr;
						indices[fidx++] = tr+1;
						indices[fidx++] = br+1;
						indices[fidx++] = bl+1;
						indices[fidx++] = tr+1;
						indices[fidx++] = bl+1;
						indices[fidx++] = tl+1;
					}
				}
			}
			
			inc += 2*(_segmentsW + 1)*(_segmentsD + 1);
			
			for (i = 0; i <= _segmentsD; i++) {
				outer_pos = hd - i*dd;
				
				for (j = 0; j <= _segmentsH; j++) {
					// left
					data[vidx++] = -hw;
					data[vidx++] = -hh + j*dh;
					data[vidx++] = outer_pos;
					data[vidx++] = -1;
					data[vidx++] = 0;
					data[vidx++] = 0;
					data[vidx++] = 0;
					data[vidx++] = 0;
					data[vidx++] = -1;
					vidx += skip;
					
					// right
					data[vidx++] = hw;
					data[vidx++] = -hh + j*dh;
					data[vidx++] = outer_pos;
					data[vidx++] = 1;
					data[vidx++] = 0;
					data[vidx++] = 0;
					data[vidx++] = 0;
					data[vidx++] = 0;
					data[vidx++] = 1;
					vidx += skip;
					
					if (i && j) {
						tl = inc + 2 * ((i-1) * (_segmentsH + 1) + (j-1));
						tr = inc + 2 * (i * (_segmentsH + 1) + (j-1));
						bl = tl + 2;
						br = tr + 2;
						
						indices[fidx++] = tl;
						indices[fidx++] = bl;
						indices[fidx++] = br;
						indices[fidx++] = tl;
						indices[fidx++] = br;
						indices[fidx++] = tr;
						indices[fidx++] = tr+1;
						indices[fidx++] = br+1;
						indices[fidx++] = bl+1;
						indices[fidx++] = tr+1;
						indices[fidx++] = bl+1;
						indices[fidx++] = tl+1;
					}
				}
			}
			
			target.indices=indices;
//			target.updateVertexAttribute(data, attributes);
			buildUVs(target, data);
			addSubGeometry(target);
		}
		
		protected function buildUVs(target : SubGeometry3D, data: Float32Array) : void
		{
			var i : uint, j : uint, uidx : uint;
//			var data : Float32Array;
			
			var u_tile_dim : Number, v_tile_dim : Number;
			var u_tile_step : Number, v_tile_step : Number;
			var tl0u : Number, tl0v : Number;
			var tl1u : Number, tl1v : Number;
			var du : Number, dv : Number;
			var stride:uint = 13;
			var numUvs : uint = ((_segmentsW + 1) * (_segmentsH + 1) +
				(_segmentsW + 1) * (_segmentsD + 1) +
				(_segmentsH + 1) * (_segmentsD + 1)) * 2 * stride;
			var skip:uint = stride - 2;
			
//			data = new Float32Array(numUvs, true);
			
			if (_tile6) {
				u_tile_dim = u_tile_step = 1/3;
				v_tile_dim = v_tile_step = 1/2;
			}
			else {
				u_tile_dim = v_tile_dim = 1;
				u_tile_step = v_tile_step = 0;
			}
			
			// Create planes two and two, the same way that they were
			// constructed in the buildGeometry() function. First calculate
			// the top-left UV coordinate for both planes, and then loop
			// over the points, calculating the UVs from these numbers.
			
			// When tile6 is true, the layout is as follows:
			//       .-----.-----.-----. (1,1)
			//       | Bot |  T  | Bak |
			//       |-----+-----+-----|
			//       |  L  |  F  |  R  |
			// (0,0)'-----'-----'-----'
			
			uidx = 9;
			
			// FRONT / BACK
			tl0u = 1 * u_tile_step;
			tl0v = 1 * v_tile_step;
			tl1u = 2 * u_tile_step;
			tl1v = 0 * v_tile_step;
			du = u_tile_dim / _segmentsW;
			dv = v_tile_dim / _segmentsH;
			for (i=0; i<=_segmentsW; i++) {
				for (j=0; j<=_segmentsH; j++) {
					data[uidx++] = tl0u + i * du;
					data[uidx++] = tl0v + (v_tile_dim - j * dv);
					uidx += skip;
					data[uidx++] = tl1u + (u_tile_dim - i * du);
					data[uidx++] = tl1v + (v_tile_dim - j * dv);
					uidx += skip;
				}
			}
			
			// TOP / BOTTOM
			tl0u = 1 * u_tile_step;
			tl0v = 0 * v_tile_step;
			tl1u = 0 * u_tile_step;
			tl1v = 0 * v_tile_step;
			du = u_tile_dim / _segmentsW;
			dv = v_tile_dim / _segmentsD;
			for (i=0; i<=_segmentsW; i++) {
				for (j=0; j<=_segmentsD; j++) {
					data[uidx++] = tl0u + i * du;
					data[uidx++] = tl0v + (v_tile_dim - j * dv);
					uidx += skip;
					data[uidx++] = tl1u + i * du;
					data[uidx++] = tl1v + j * dv;
					uidx += skip;
				}
			}
			
			// LEFT / RIGHT
			tl0u = 0 * u_tile_step;
			tl0v = 1 * v_tile_step;
			tl1u = 2 * u_tile_step;
			tl1v = 1 * v_tile_step;
			du = u_tile_dim / _segmentsD;
			dv = v_tile_dim / _segmentsH;
			for (i=0; i<=_segmentsD; i++) {
				for (j=0; j<=_segmentsH; j++) {
					data[uidx++] = tl0u + i * du;
					data[uidx++] = tl0v + (v_tile_dim - j * dv);
					uidx += skip;
					data[uidx++] = tl1u + (u_tile_dim - i * du);
					data[uidx++] = tl1v + (v_tile_dim - j * dv);
					uidx += skip;
				}
			}
			target.updateVertexAttribute(data, GeomUtil.SUB_GEOMETRY_ATTRIBUTES);
		}
		
	}
}
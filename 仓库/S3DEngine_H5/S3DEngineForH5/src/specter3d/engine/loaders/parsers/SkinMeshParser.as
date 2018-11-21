package specter3d.engine.loaders.parsers
{
	public final class SkinMeshParser extends ParserBase
	{

		private static const COMMENT_TOKEN:String="//";
		private static const VERSION_TOKEN : String = "MD5Version";
		
		public function SkinMeshParser()
		{
			super(ParserDataFormat.PLAIN_TEXT);
		}
		private var _charLineIndex:int;
		private var _line:int;
		private var _parseIndex:int;
		private var _reachedEOF:Boolean;
		private var _textData:String=null;

		override protected function proceedParsing():Boolean
		{
			var token:String;
			if (_textData == null)
			{
				_textData=getTextData();
			}

			token=getNextToken();
			switch (token) 
			{
				case COMMENT_TOKEN:
					ignoreLine();
					break;
				case VERSION_TOKEN:
					_version = getNextInt();
					if (_version != 10) throw new Error("Unknown version number encountered!");
					break;
			}
			return false;
		}
		
		private function getNextInt() : int
		{
			var i : Number = parseInt(getNextToken());
			if (isNaN(i)) sendParseError("int type");
			return i;
		}

		private function sendParseError(expected : String) : void
		{
			throw new Error("Unexpected token at line " + (_line + 1) + ", character " + _charLineIndex + ". " + expected + " expected, but " + _textData.charAt(_parseIndex - 1) + " encountered");
		}
		
		private function ignoreLine() : void
		{
			var ch : String;
			while (!_reachedEOF && ch != "\n")
				ch = getNextChar();
		}
		
		private function getNextChar():String
		{
			var ch:String=_textData.charAt(_parseIndex++);

			if (ch == "\n")
			{
				++_line;
				_charLineIndex=0;
			}
			else if (ch != "\r")
				++_charLineIndex;

			if (_parseIndex >= _textData.length)
				_reachedEOF=true;

			return ch;
		}

		private function getNextToken():String
		{
			var ch:String;
			var token:String="";

			while (!_reachedEOF)
			{
				ch=getNextChar();
				if (ch == " " || ch == "\r" || ch == "\n" || ch == "\t")
				{
					if (token != COMMENT_TOKEN)
						skipWhiteSpace();
					if (token != "")
						return token;
				}
				else
					token+=ch;

				if (token == COMMENT_TOKEN)
					return token;
			}
			return token;
		}

		private function putBack():void
		{
			_parseIndex--;
			_charLineIndex--;
			_reachedEOF=_parseIndex >= _textData.length;
		}

		private function skipWhiteSpace():void
		{
			var ch:String;

			do
			{
				ch=getNextChar();
			} while (ch == "\n" || ch == " " || ch == "\r" || ch == "\t");

			putBack();
		}
	}
}

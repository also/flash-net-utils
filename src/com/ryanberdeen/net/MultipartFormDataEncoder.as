package com.ryanberdeen.net {
  import flash.utils.ByteArray;
  import flash.utils.Endian;

  public class MultipartFormDataEncoder {
    private var _boundary:String;
    private var _postData:ByteArray;
    private var finished:Boolean;

    public function MultipartFormDataEncoder() {
      _postData = new ByteArray();
      _postData.endian = Endian.BIG_ENDIAN;

      _boundary = '';
      for (var i:int = 0; i < 0x20; i++) {
        _boundary += String.fromCharCode(int(97 + Math.random() * 25));
      }
    }

    public function addParameter(name:String, value:Object):void {
      if (value == null) {
        value = '';
      }
      writeBoundary();
      writeLinebreak();
      writeString('Content-Disposition: form-data; name="' + name + '"');
      writeLinebreak();
      writeLinebreak();
      _postData.writeUTFBytes(value.toString());
      writeLinebreak();
    }

    public function addParameters(parameters:Object):void {
      for(var name:String in parameters) {
        addParameter(name, parameters[name]);
      }
    }

    public function addFile(parameterName:String, filename:String, data:ByteArray, contentType:String = 'application/octet-stream'):void {
      writeBoundary();
      writeLinebreak();
      writeString('Content-Disposition: form-data; name="' + parameterName + '"; filename="');
      _postData.writeUTFBytes(filename);
      writeString('"');
      writeLinebreak();
      writeString('Content-Type: ' + contentType);
      writeLinebreak();
      writeLinebreak();
      _postData.writeBytes(data);
      writeLinebreak();
    }

    private function writeString(string:String):void {
      for (var i:int = 0; i < string.length; i++) {
        _postData.writeByte(string.charCodeAt(i));
      }
    }

    private function finish():void {
      writeBoundary();
      writeDoubleDash();
    }

    public function get data():ByteArray {
      if (!finished) {
        finish();
      }
      return _postData;
    }

    public function get boundary():String {
      return _boundary;
    }

    private function writeBoundary():void {
      var length:int = _boundary.length;

      writeDoubleDash();
      for (var i:int = 0; i < length; i++) {
        _postData.writeByte(_boundary.charCodeAt(i));
      }
    }

    private function writeLinebreak():void {
      _postData.writeShort(0x0d0a);
    }

    private function writeDoubleDash():void {
      _postData.writeShort(0x2d2d);
    }
  }
}

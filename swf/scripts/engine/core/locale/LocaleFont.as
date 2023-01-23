package engine.core.locale
{
   import flash.errors.IllegalOperationError;
   import flash.utils.Dictionary;
   
   public class LocaleFont
   {
      
      public static const FACE_M:String = "Minion Pro";
      
      public static const FACE_V:String = "Vinque";
      
      private static var _fontsByFace:Dictionary = new Dictionary();
      
      private static var _fontsById:Dictionary = new Dictionary();
       
      
      public var id:String;
      
      public var face:String;
      
      public var offsetY:int;
      
      public var sizeMod:int;
      
      public var deIcelandic:Boolean;
      
      public function LocaleFont(param1:String, param2:String, param3:int, param4:int, param5:Boolean)
      {
         super();
         this.id = param1;
         this.face = param2;
         this.offsetY = param3;
         this.sizeMod = param4;
         this.deIcelandic = param5;
      }
      
      public static function fetchByFace(param1:String) : LocaleFont
      {
         return _fontsByFace[param1];
      }
      
      public static function fetchById(param1:String) : LocaleFont
      {
         return _fontsById[param1];
      }
      
      public static function register(param1:LocaleFont) : void
      {
         if(_fontsByFace[param1.face])
         {
            throw new IllegalOperationError("adding duplicate LocaleFont face " + param1);
         }
         if(_fontsById[param1.id])
         {
            throw new IllegalOperationError("adding duplicate LocaleFont id " + param1);
         }
         _fontsByFace[param1.face] = param1;
         _fontsById[param1.id] = param1;
      }
      
      public static function init() : void
      {
         register(new LocaleFont("ru_v","VinqueRU",0,0,false));
         register(new LocaleFont("jp_v","AFP駿河-M",8,0,true));
         register(new LocaleFont("ko_v","제주고딕",10,-2,true));
         register(new LocaleFont("zh_v","方正隶书简体",2,6,true));
         register(new LocaleFont("jp_m","02うつくし明朝体",0,0,true));
         register(new LocaleFont("ko_m","나눔바른고딕",-2,-4,true));
         register(new LocaleFont("zh_m","方正新书宋简体",0,-3,true));
      }
   }
}

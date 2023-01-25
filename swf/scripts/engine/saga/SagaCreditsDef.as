package engine.saga
{
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import engine.core.util.ArrayUtil;
   import engine.def.EngineJsonDef;
   import engine.expression.ISymbols;
   import flash.errors.IllegalOperationError;
   import flash.utils.Dictionary;
   
   public class SagaCreditsDef
   {
      
      public static const schema:Object = {
         "name":"SagaCreditsDef",
         "type":"object",
         "properties":{
            "texts":{
               "type":"object",
               "optional":true,
               "skip":true
            },
            "textses":{
               "type":"array",
               "items":SagaCreditsTextDef.schema,
               "optional":true
            },
            "images":{
               "type":"array",
               "items":SagaCreditsImageDef.schema,
               "optional":true
            },
            "bgcolor":{
               "type":"string",
               "optional":true
            },
            "bgurl":{
               "type":"string",
               "optional":true
            },
            "textcolor":{
               "type":"string",
               "optional":true
            },
            "headercolor":{
               "type":"string",
               "optional":true
            },
            "imagecolor":{
               "type":"string",
               "optional":true
            },
            "imagespeed":{
               "type":"number",
               "optional":true
            }
         }
      };
       
      
      public var json:Object;
      
      public var imageDefs:Vector.<SagaCreditsImageDef>;
      
      public var bgcolor:uint = 4278190080;
      
      public var textcolor:uint = 4294967295;
      
      public var headercolor:uint = 4294967295;
      
      public var imagecolor:uint = 4294967295;
      
      public var imagespeed:Number = 0.5;
      
      public var textses:Vector.<SagaCreditsTextDef>;
      
      public var textsesByLocaleId:Dictionary;
      
      public var bgurl:String;
      
      public function SagaCreditsDef()
      {
         this.imageDefs = new Vector.<SagaCreditsImageDef>();
         this.textses = new Vector.<SagaCreditsTextDef>();
         this.textsesByLocaleId = new Dictionary();
         super();
      }
      
      public static function vctor() : Vector.<SagaCreditsDef>
      {
         return new Vector.<SagaCreditsDef>();
      }
      
      private function addText(param1:SagaCreditsTextDef) : void
      {
         this.textses.push(param1);
         this.handleAddedText(param1,this.textses.length - 1);
      }
      
      private function handleAddedText(param1:SagaCreditsTextDef, param2:int) : void
      {
         this.textsesByLocaleId[param1.localeId] = param1;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : SagaCreditsDef
      {
         var _loc3_:Object = null;
         var _loc4_:SagaCreditsImageDef = null;
         EngineJsonDef.validateThrow(param1,schema,param2);
         if(!param1)
         {
            throw new ArgumentError("no credits?");
         }
         this.json = param1;
         if(param1.textses)
         {
            this.textses = ArrayUtil.arrayToDefVector(param1.textses,SagaCreditsTextDef,param2,this.textses,this.handleAddedText) as Vector.<SagaCreditsTextDef>;
         }
         else if(param1.texts)
         {
            this._processOldTexts(param1.texts);
         }
         if(!this.textsesByLocaleId[Locale.en_id])
         {
            throw new ArgumentError("No \'en\' credits");
         }
         if(param1.images)
         {
            for each(_loc3_ in param1.images)
            {
               _loc4_ = new SagaCreditsImageDef().fromJson(_loc3_,param2);
               this.imageDefs.push(_loc4_);
            }
         }
         this.bgurl = param1.bgurl;
         if(param1.bgcolor)
         {
            this.bgcolor = uint(param1.bgcolor);
         }
         if(param1.textcolor)
         {
            this.textcolor = uint(param1.textcolor);
         }
         if(param1.headercolor)
         {
            this.headercolor = uint(param1.headercolor);
         }
         if(param1.imagecolor)
         {
            this.imagecolor = uint(param1.imagecolor);
         }
         if(param1.imagespeed != undefined)
         {
            this.imagespeed = param1.imagespeed;
         }
         return this;
      }
      
      private function _processOldTexts(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:Object = null;
         var _loc4_:SagaCreditsTextDef = null;
         if(!param1)
         {
            return;
         }
         for(_loc2_ in param1)
         {
            _loc3_ = param1[_loc2_];
            _loc4_ = new SagaCreditsTextDef();
            _loc4_.localeId = _loc2_;
            _loc4_.textsUrls.push(_loc3_.url);
            _loc4_.logoUrl = _loc3_.logo;
            this.addText(_loc4_);
         }
      }
      
      public function toJson() : Object
      {
         return this.json;
      }
      
      public function getLocaleTextDef(param1:String) : SagaCreditsTextDef
      {
         var _loc2_:SagaCreditsTextDef = this.textsesByLocaleId[param1];
         if(!_loc2_)
         {
            _loc2_ = this.textsesByLocaleId[Locale.en_id];
         }
         if(!_loc2_)
         {
            throw new IllegalOperationError("no text");
         }
         return _loc2_;
      }
      
      public function fetchImageList(param1:ISymbols, param2:Vector.<String>, param3:ILogger) : Vector.<String>
      {
         var _loc4_:SagaCreditsImageDef = null;
         if(!param2)
         {
            param2 = new Vector.<String>();
         }
         for each(_loc4_ in this.imageDefs)
         {
            if(_loc4_.checkPrereq(param1,param3))
            {
               param2.push(_loc4_.url);
            }
         }
         return param2;
      }
   }
}

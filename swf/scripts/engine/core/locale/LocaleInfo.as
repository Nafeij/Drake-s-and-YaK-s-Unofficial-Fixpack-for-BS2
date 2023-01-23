package engine.core.locale
{
   import flash.errors.IllegalOperationError;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.Dictionary;
   
   public class LocaleInfo
   {
      
      public static var terminators_en:Array = [" ",".","?","!",",",";"];
      
      private static var _terminators:Object = {"jp":["力","防","、","体","<","意","ブ","人","名","物","再","回","。","の","は","日","あ","に","と","）","を","以","パ"]};
      
      private static var _infos:Dictionary = new Dictionary();
       
      
      public var font_v:LocaleFont;
      
      public var font_m:LocaleFont;
      
      public var terminators:Array;
      
      public var localeId:LocaleId;
      
      public var isEn:Boolean;
      
      public var deIcelandic:Boolean;
      
      public function LocaleInfo(param1:LocaleId)
      {
         super();
         if(_infos[param1.id])
         {
            throw new IllegalOperationError("Already have a LocaleInfo for " + param1);
         }
         this.localeId = param1;
         if(param1.id == Locale.en_id)
         {
            this.isEn = true;
         }
         this.terminators = _terminators[param1.id];
         this.font_v = LocaleFont.fetchById(param1 + "_v");
         this.font_m = LocaleFont.fetchById(param1 + "_m");
         this.deIcelandic = Boolean(this.font_v) && this.font_v.deIcelandic || Boolean(this.font_m) && this.font_m.deIcelandic;
         _infos[param1.id] = this;
      }
      
      public static function fetch(param1:String) : LocaleInfo
      {
         var _loc2_:LocaleInfo = _infos[param1];
         if(!_loc2_)
         {
            _loc2_ = new LocaleInfo(new LocaleId(param1));
            _infos[param1] = _loc2_;
         }
         return _loc2_;
      }
      
      public static function resetTextFieldFormat(param1:TextField, param2:int) : void
      {
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:TextFormat = null;
         var _loc8_:TextFormat = null;
         var _loc3_:TextFormat = param1.getTextFormat();
         var _loc4_:TextFormat = param1.defaultTextFormat;
         if(Boolean(_loc3_) && Boolean(_loc4_))
         {
            _loc5_ = _loc3_.font;
            _loc6_ = _loc4_.font;
            if(_loc5_)
            {
               if(_loc6_.indexOf("Minion Pro") == 0 && _loc5_.indexOf("Minion Pro") == 0)
               {
                  return;
               }
            }
            _loc8_ = _loc4_;
            _loc7_ = new TextFormat(_loc8_.font,_loc8_.size + param2,null);
            param1.setTextFormat(_loc7_);
         }
      }
      
      private static function _findEndPlace(param1:int, param2:int) : int
      {
         if(param2 >= 0)
         {
            if(param1 < 0 || param1 > param2)
            {
               return param2;
            }
         }
         return param1;
      }
      
      public static function getTokenBreakPos(param1:String, param2:int) : int
      {
         var _loc4_:String = null;
         var _loc3_:int = -1;
         for each(_loc4_ in LocaleInfo.terminators_en)
         {
            _loc3_ = _findEndPlace(_loc3_,param1.indexOf(_loc4_,param2));
         }
         if(_loc3_ < 0)
         {
            _loc3_ = param1.length;
         }
         return _loc3_;
      }
      
      public function _fixTextFieldFormat(param1:TextField, param2:String = null, param3:* = null, param4:Boolean = true, param5:int = 0) : Boolean
      {
         var _loc6_:String = null;
         var _loc7_:TextFormat = null;
         var _loc9_:LocaleInfo = null;
         if(!param1)
         {
            return false;
         }
         if(param2)
         {
            _loc9_ = LocaleInfo.fetch(param2);
            if(_loc9_)
            {
               return _loc9_._fixTextFieldFormat(param1,null,param3,param4,param5);
            }
         }
         var _loc8_:TextFormat = param1.defaultTextFormat;
         if(this.font_v)
         {
            if(Locale.isFontVinque(_loc8_.font))
            {
               if(param3 == null)
               {
                  if(param4)
                  {
                  }
               }
               _loc6_ = this.font_v.face;
               param5 += this.font_v.sizeMod;
               _loc7_ = new TextFormat(_loc6_,_loc8_.size + param5,param3);
               param1.setTextFormat(_loc7_);
               return true;
            }
         }
         if(this.font_m)
         {
            if(Locale.isFontMinion(_loc8_.font))
            {
               if(param3 == null)
               {
                  if(!param4)
                  {
                     param3 = _loc8_.color;
                  }
               }
               _loc6_ = this.font_m.face;
               param5 += this.font_m.sizeMod;
               _loc7_ = new TextFormat(_loc6_,_loc8_.size + param5,param3);
               param1.setTextFormat(_loc7_);
               return true;
            }
         }
         resetTextFieldFormat(param1,param5);
         return false;
      }
   }
}

package engine.core.locale
{
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.gui.IGuiGpTextHelperFactory;
   
   public class LocaleVars extends Locale
   {
       
      
      public function LocaleVars(param1:LocaleId, param2:IGuiGpTextHelperFactory, param3:Object, param4:Class, param5:Boolean, param6:ILogger)
      {
         var _loc7_:* = null;
         var _loc8_:Object = null;
         var _loc9_:LocaleCategory = null;
         var _loc10_:Localizer = null;
         super(param1,param2,param6);
         for(_loc7_ in param3)
         {
            _loc8_ = param3[_loc7_];
            _loc9_ = Enum.parse(param4,_loc7_) as LocaleCategory;
            _loc10_ = new Localizer(_loc9_,param6).init(_loc8_,param5);
            addLocalizer(_loc10_);
         }
      }
      
      public static function save(param1:Locale) : Object
      {
         var _loc3_:Localizer = null;
         var _loc2_:Object = {};
         for each(_loc3_ in param1.localizerList)
         {
            _loc2_[_loc3_.id.name] = Localizer.save(_loc3_);
         }
         return _loc2_;
      }
   }
}

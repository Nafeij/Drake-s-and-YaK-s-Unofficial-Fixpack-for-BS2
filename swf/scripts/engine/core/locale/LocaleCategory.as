package engine.core.locale
{
   import engine.core.util.Enum;
   
   public class LocaleCategory extends Enum
   {
      
      public static const BATTLE_OBJ:LocaleCategory = new LocaleCategory("BATTLE_OBJ",enumCtorKey);
      
      public static const IAP:LocaleCategory = new LocaleCategory("IAP",enumCtorKey);
      
      public static const ENTITY:LocaleCategory = new LocaleCategory("ENTITY",enumCtorKey);
      
      public static const ABILITY:LocaleCategory = new LocaleCategory("ABILITY",enumCtorKey);
      
      public static const GUI:LocaleCategory = new LocaleCategory("GUI",enumCtorKey);
      
      public static const SPEAK:LocaleCategory = new LocaleCategory("SPEAK",enumCtorKey);
      
      public static const GUI_MOBILE:LocaleCategory = new LocaleCategory("GUI_MOBILE",enumCtorKey);
      
      public static const GUI_GP:LocaleCategory = new LocaleCategory("GUI_GP",enumCtorKey);
      
      public static const GUI_GP_ALT:LocaleCategory = new LocaleCategory("GUI_GP_ALT",enumCtorKey);
      
      public static const GUI_VITA:LocaleCategory = new LocaleCategory("GUI_VITA",enumCtorKey);
      
      public static const TAUNT:LocaleCategory = new LocaleCategory("TAUNT",enumCtorKey);
      
      public static const ACHIEVEMENT:LocaleCategory = new LocaleCategory("ACHIEVEMENT",enumCtorKey);
      
      public static const FLYTEXT:LocaleCategory = new LocaleCategory("FLYTEXT",enumCtorKey);
      
      public static const TUTORIAL:LocaleCategory = new LocaleCategory("TUTORIAL",enumCtorKey);
      
      public static const TUTORIAL_MOBILE:LocaleCategory = new LocaleCategory("TUTORIAL_MOBILE",enumCtorKey);
      
      public static const TUTORIAL_GP:LocaleCategory = new LocaleCategory("TUTORIAL_GP",enumCtorKey);
      
      public static const TUTORIAL_GP_ALT:LocaleCategory = new LocaleCategory("TUTORIAL_GP_ALT",enumCtorKey);
      
      public static const ITEM:LocaleCategory = new LocaleCategory("ITEM",enumCtorKey);
      
      public static const STAT:LocaleCategory = new LocaleCategory("STAT",enumCtorKey);
      
      public static const LOCATION:LocaleCategory = new LocaleCategory("LOCATION",enumCtorKey);
      
      public static const LORE:LocaleCategory = new LocaleCategory("LORE",enumCtorKey);
      
      public static const SUBTITLE:LocaleCategory = new LocaleCategory("SUBTITLE",enumCtorKey);
      
      public static const GP:LocaleCategory = new LocaleCategory("GP",enumCtorKey);
      
      public static const TALENT:LocaleCategory = new LocaleCategory("TALENT",enumCtorKey);
      
      public static const LEADERBOARD:LocaleCategory = new LocaleCategory("LEADERBOARD",enumCtorKey);
      
      public static const PLATFORM:LocaleCategory = new LocaleCategory("PLATFORM",enumCtorKey);
      
      public static const GUI_GP_XB1:LocaleCategory = new LocaleCategory("GUI_GP_XB1",enumCtorKey);
      
      public static const GUI_GP_PS4:LocaleCategory = new LocaleCategory("GUI_GP_PS4",enumCtorKey);
      
      public static const PLATFORM_XB1:LocaleCategory = new LocaleCategory("PLATFORM_XB1",enumCtorKey);
      
      public static const PLATFORM_PS4:LocaleCategory = new LocaleCategory("PLATFORM_PS4",enumCtorKey);
      
      public static const CLICK:LocaleCategory = new LocaleCategory("CLICK",enumCtorKey);
      
      public static const TITLE:LocaleCategory = new LocaleCategory("TITLE",enumCtorKey);
      
      public static const CARTS:LocaleCategory = new LocaleCategory("CARTS",enumCtorKey);
      
      public static var overlayable:Array = [GUI,TUTORIAL,TUTORIAL_GP,GUI_GP,PLATFORM];
       
      
      public var overlay:LocaleCategory;
      
      public function LocaleCategory(param1:String, param2:*)
      {
         super(param1,param2);
      }
      
      public static function setupMobileLocaleOverlays() : void
      {
         GUI.overlay = GUI_MOBILE;
         TUTORIAL.overlay = TUTORIAL_MOBILE;
      }
      
      public static function setupXb1LocaleOverlays() : void
      {
         PLATFORM.overlay = PLATFORM_XB1;
         appendOverlay(GUI_GP,GUI_GP_XB1);
      }
      
      public static function setupPsnLocaleOverlays() : void
      {
         PLATFORM.overlay = PLATFORM_PS4;
         appendOverlay(GUI_GP,GUI_GP_PS4);
      }
      
      public static function setAltGpOverlay() : void
      {
         TUTORIAL_GP.overlay = TUTORIAL_GP_ALT;
         appendOverlay(GUI_GP,GUI_GP_ALT);
      }
      
      private static function appendOverlay(param1:LocaleCategory, param2:LocaleCategory) : void
      {
         while(param1.overlay)
         {
            param1 = param1.overlay;
         }
         param1.overlay = param2;
         if(overlayable.indexOf(param1) == -1)
         {
            overlayable.push(param1);
         }
      }
   }
}

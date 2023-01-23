package engine.core
{
   import engine.core.util.Enum;
   import flash.utils.Dictionary;
   
   public class RunMode extends Enum
   {
      
      public static const KIOSK:RunMode = new RunMode("KIOSK",true,true,true,false,false,enumCtorKey);
      
      public static const BETA:RunMode = new RunMode("BETA",true,false,true,false,false,enumCtorKey);
      
      public static const FACTIONS:RunMode = new RunMode("FACTIONS",true,false,true,false,false,enumCtorKey);
      
      private static var available_classes:Dictionary;
       
      
      public var fullscreen:Boolean;
      
      public var autologin:Boolean;
      
      public var town:Boolean;
      
      public var developer:Boolean;
      
      public var mainMenu:Boolean;
      
      public function RunMode(param1:String, param2:Boolean, param3:Boolean, param4:Boolean, param5:Boolean, param6:Boolean, param7:Object)
      {
         super(param1,param7);
         this.fullscreen = param2;
         this.autologin = param3;
         this.town = param4;
         this.mainMenu = param5;
         this.developer = param6;
      }
      
      public function isClassAvailable(param1:String) : Boolean
      {
         if(!available_classes)
         {
            available_classes = new Dictionary();
            available_classes["warhawk"] = true;
            available_classes["provoker"] = true;
            available_classes["skystriker"] = true;
            available_classes["thrasher"] = true;
            available_classes["backbiter"] = true;
            available_classes["siegearcher"] = true;
            available_classes["archer"] = true;
            available_classes["axeman"] = true;
            available_classes["shieldbanger"] = true;
            available_classes["warrior"] = true;
            available_classes["strongarm"] = true;
            available_classes["warmaster"] = true;
            available_classes["bowmaster"] = true;
            available_classes["axemaster"] = true;
            available_classes["shieldmaster"] = true;
            available_classes["warleader"] = true;
         }
         if(this.developer)
         {
            return true;
         }
         return param1 in available_classes;
      }
   }
}

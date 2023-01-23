package engine.saga
{
   import engine.core.locale.Locale;
   
   public class FlyInfo
   {
       
      
      public var color:uint;
      
      public var labelUp:String;
      
      public var labelDown:String;
      
      public var soundIdUp:String;
      
      public var soundIdDown:String;
      
      public var linger:Number = 0;
      
      public function FlyInfo(param1:Locale, param2:String, param3:String, param4:String, param5:uint, param6:String, param7:String)
      {
         super();
         this.color = param5;
         this.labelUp = !!param3 ? param1.translateGui(param3) : null;
         this.labelDown = !!param4 ? param1.translateGui(param4) : null;
         this.soundIdDown = param7;
         this.soundIdUp = param6;
      }
   }
}

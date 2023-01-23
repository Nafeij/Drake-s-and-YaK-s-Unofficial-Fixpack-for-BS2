package engine.landscape.view
{
   import engine.saga.vars.IVariableBag;
   import engine.saga.vars.VariableEvent;
   import engine.saga.vars.VariableType;
   
   public class WeatherManager_Blinker extends WeatherManager_Particle
   {
       
      
      private var _varname_blinkrate:String;
      
      private var _blinkRate:Number = 1;
      
      public function WeatherManager_Blinker(param1:String, param2:WeatherManager, param3:String, param4:String, param5:String, param6:String, param7:String)
      {
         super(param1,param2,param3,param4,param5,param6);
         this._varname_blinkrate = param7;
      }
      
      override public function variableHandler(param1:VariableEvent) : Boolean
      {
         if(!super.variableHandler(param1))
         {
            if(param1.value.def.name == this._varname_blinkrate)
            {
               this._blinkRate = param1.value.asNumber;
               return true;
            }
         }
         return false;
      }
      
      override public function getVariables(param1:IVariableBag) : void
      {
         if(!param1)
         {
            return;
         }
         super.getVariables(param1);
         this._blinkRate = param1.fetch(this._varname_blinkrate,VariableType.DECIMAL).asNumber;
      }
      
      public function get blinkRate() : Number
      {
         return this._blinkRate;
      }
      
      public function set blinkRate(param1:Number) : void
      {
         this._blinkRate = param1;
      }
   }
}

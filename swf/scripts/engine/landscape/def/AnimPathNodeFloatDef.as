package engine.landscape.def
{
   import engine.core.logging.ILogger;
   import engine.core.util.UtilFunctions;
   import engine.def.EngineJsonDef;
   
   public class AnimPathNodeFloatDef extends AnimPathNodeDef
   {
      
      public static const schema:Object = {
         "name":"AnimPathNodeFloatDef",
         "type":"object",
         "properties":{
            "type":{"type":"string"},
            "start_secs":{
               "type":"number",
               "optional":true
            },
            "duration_secs":{"type":"number"},
            "y_amplitude":{"type":"number"},
            "y_period":{"type":"number"},
            "x_amplitude":{"type":"number"},
            "x_period":{"type":"number"},
            "rot_amplitude":{"type":"number"},
            "rot_period":{"type":"number"}
         }
      };
       
      
      public var y_amplitude:Number = 100;
      
      public var y_period:Number = 1;
      
      public var x_amplitude:Number = 100;
      
      public var x_period:Number = 2;
      
      public var rot_amplitude:Number = 30;
      
      public var rot_period:Number = 3;
      
      public function AnimPathNodeFloatDef()
      {
         super();
         this.continuous = true;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : AnimPathNodeFloatDef
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.startTimeSecs = param1.start_secs;
         this.durationSecs = param1.duration_secs;
         this.y_amplitude = param1.y_amplitude;
         this.y_period = param1.y_period;
         this.x_amplitude = param1.x_amplitude;
         this.x_period = param1.x_period;
         this.rot_amplitude = param1.rot_amplitude;
         this.rot_period = param1.rot_period;
         return this;
      }
      
      public function save() : Object
      {
         return {
            "type":AnimPathType.FLOAT.name,
            "start_secs":UtilFunctions.safety(startTimeSecs),
            "duration_secs":UtilFunctions.safety(durationSecs),
            "y_amplitude":UtilFunctions.safety(this.y_amplitude),
            "y_period":UtilFunctions.safety(this.y_period),
            "x_amplitude":UtilFunctions.safety(this.x_amplitude),
            "x_period":UtilFunctions.safety(this.x_period),
            "rot_amplitude":UtilFunctions.safety(this.rot_amplitude),
            "rot_period":UtilFunctions.safety(this.rot_period)
         };
      }
      
      override public function get labelString() : String
      {
         return startTimeSecs + ": FLOAT " + this.y_amplitude + " per " + this.y_period + " in " + durationSecs;
      }
      
      override public function clone() : AnimPathNodeDef
      {
         var _loc1_:AnimPathNodeFloatDef = new AnimPathNodeFloatDef();
         _loc1_.copyFromBase(this);
         _loc1_.y_amplitude = this.y_amplitude;
         _loc1_.y_period = this.y_period;
         _loc1_.x_amplitude = this.x_amplitude;
         _loc1_.x_period = this.x_period;
         _loc1_.rot_amplitude = this.rot_amplitude;
         _loc1_.rot_period = this.rot_period;
         return _loc1_;
      }
   }
}

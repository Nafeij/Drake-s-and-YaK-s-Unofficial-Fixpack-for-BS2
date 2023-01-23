package engine.landscape.def
{
   import engine.core.logging.ILogger;
   import engine.core.util.UtilFunctions;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   import engine.def.PointVars;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class AnimPathNodeRotateDef extends AnimPathNodeDef_MotionBase
   {
      
      public static const schema:Object = {
         "name":"AnimPathNodeRotateDef",
         "type":"object",
         "properties":{
            "type":{"type":"string"},
            "degrees_start":{"type":"number"},
            "degrees_end":{"type":"number"},
            "pivot":{"type":"string"},
            "start_secs":{
               "type":"number",
               "optional":true
            },
            "duration_secs":{"type":"number"},
            "ease":{
               "type":"string",
               "optional":true
            },
            "easeIn":{
               "type":"boolean",
               "optional":true
            },
            "easeOut":{
               "type":"boolean",
               "optional":true
            },
            "continuous":{
               "type":"boolean",
               "optional":true
            }
         }
      };
       
      
      public var degrees_start:Number = 0;
      
      public var degrees_end:Number = 0;
      
      public var pivot:Point;
      
      public function AnimPathNodeRotateDef()
      {
         this.pivot = new Point();
         super();
      }
      
      override public function get labelString() : String
      {
         return startTimeSecs + ": ROTATE " + this.degrees_start + "° -> " + this.degrees_end + "° in " + durationSecs;
      }
      
      override public function clone() : AnimPathNodeDef
      {
         var _loc1_:AnimPathNodeRotateDef = new AnimPathNodeRotateDef();
         _loc1_.degrees_start = this.degrees_start;
         _loc1_.degrees_end = this.degrees_end;
         _loc1_.pivot = this.pivot.clone();
         _loc1_.copyFromMotionBase(this);
         return _loc1_;
      }
      
      override public function getBounds(param1:Rectangle) : Rectangle
      {
         return param1;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : AnimPathNodeRotateDef
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.startTimeSecs = param1.start_secs;
         this.degrees_start = param1.degrees_start;
         this.degrees_end = param1.degrees_end;
         this.durationSecs = param1.duration_secs;
         this.pivot = PointVars.parseString(param1.pivot,this.pivot);
         if(param1.ease != undefined)
         {
            this.ease = param1.ease;
         }
         this.easeIn = BooleanVars.parse(param1.easeIn,this.easeIn);
         this.easeOut = BooleanVars.parse(param1.easeOut,this.easeOut);
         this.continuous = BooleanVars.parse(param1.continuous,true);
         return this;
      }
      
      public function save() : Object
      {
         return {
            "type":AnimPathType.ROTATE.name,
            "degrees_start":this.degrees_start,
            "degrees_end":this.degrees_end,
            "start_secs":this.startTimeSecs,
            "duration_secs":UtilFunctions.safety(durationSecs),
            "pivot":PointVars.saveString(this.pivot),
            "ease":(!!this.ease ? this.ease : ""),
            "easeIn":this.easeIn,
            "easeOut":this.easeOut,
            "continuous":this.continuous
         };
      }
   }
}

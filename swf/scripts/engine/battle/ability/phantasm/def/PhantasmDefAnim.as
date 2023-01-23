package engine.battle.ability.phantasm.def
{
   import engine.core.logging.ILogger;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   
   public class PhantasmDefAnim extends PhantasmDef
   {
      
      public static const schema:Object = {
         "name":"PhantasmDefAnim",
         "type":"object",
         "properties":{
            "anim":{"type":"string"},
            "killingAnim":{
               "type":"string",
               "optional":true
            },
            "ambient":{
               "type":"boolean",
               "optional":true
            },
            "freeze":{
               "type":"boolean",
               "optional":true
            },
            "unfreeze":{
               "type":"boolean",
               "optional":true
            },
            "base":{"type":PhantasmDefVars.schema},
            "noloco":{
               "type":"boolean",
               "optional":true
            },
            "reverse":{
               "type":"boolean",
               "optional":true
            },
            "priority":{
               "type":"number",
               "optional":true
            }
         }
      };
       
      
      public var ambient:Boolean;
      
      public var anim:String;
      
      public var killingAnim:String;
      
      public var freeze:Boolean;
      
      public var unfreeze:Boolean;
      
      public var noloco:Boolean;
      
      public var reverse:Boolean;
      
      public var priority:int;
      
      public function PhantasmDefAnim(param1:Object, param2:ILogger)
      {
         super();
         EngineJsonDef.validateThrow(param1,schema,param2);
         PhantasmDefVars.parse(this,param1.base,param2);
         this.anim = param1.anim;
         this.killingAnim = param1.killingAnim;
         this.ambient = BooleanVars.parse(param1.ambient,this.ambient);
         this.freeze = BooleanVars.parse(param1.freeze,this.freeze);
         this.unfreeze = BooleanVars.parse(param1.unfreeze,this.unfreeze);
         this.noloco = BooleanVars.parse(param1.noloco,this.noloco);
         this.reverse = param1.reverse;
         this.priority = param1.priority;
      }
      
      override public function toJson() : Object
      {
         var _loc1_:Object = {
            "anim":this.anim,
            "base":PhantasmDefVars.save(this)
         };
         if(this.priority)
         {
            _loc1_.priority = this.priority;
         }
         if(this.killingAnim)
         {
            _loc1_.killingAnim = this.killingAnim;
         }
         if(this.ambient)
         {
            _loc1_.ambient = this.ambient;
         }
         if(this.freeze)
         {
            _loc1_.freeze = this.freeze;
         }
         if(this.unfreeze)
         {
            _loc1_.unfreeze = this.unfreeze;
         }
         if(this.noloco)
         {
            _loc1_.noloco = this.noloco;
         }
         if(this.reverse)
         {
            _loc1_.reverse = this.reverse;
         }
         return _loc1_;
      }
      
      override public function toString() : String
      {
         return "PDAnim " + super.toString() + " anim=" + this.anim + " killing=" + this.killingAnim;
      }
   }
}

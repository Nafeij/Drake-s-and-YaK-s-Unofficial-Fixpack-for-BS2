package engine.battle.ability.phantasm.def
{
   import engine.core.logging.ILogger;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   import engine.def.NumberVars;
   
   public class PhantasmDefSprite extends PhantasmDef
   {
      
      public static const schema:Object = {
         "name":"PhantasmDefSprite",
         "description":"PhantasmDefSprite Definition",
         "type":"object",
         "properties":{
            "spriteName":{
               "type":"string",
               "optional":true
            },
            "vfx":{
               "type":VfxSequenceDef.schema,
               "optional":true
            },
            "parameter":{
               "type":"string",
               "optional":true
            },
            "parameter_value":{
               "type":"number",
               "optional":true
            },
            "oriented":{
               "type":"boolean",
               "optional":true
            },
            "useBoardVfxLib":{
               "type":"boolean",
               "optional":true
            },
            "rotate":{
               "type":"boolean",
               "optional":true,
               "description":"vfx rotate to target or caster based on target mode"
            },
            "color":{
               "type":"number",
               "optional":true
            },
            "alpha":{
               "type":"number",
               "optional":true
            },
            "height":{
               "type":"number",
               "optional":true
            },
            "base":{"type":PhantasmDefVars.schema}
         }
      };
       
      
      public var rotate:Boolean;
      
      public var color:uint = 4294967295;
      
      public var alpha:Number = 1;
      
      public var height:Number = 0.5;
      
      public var vfx:VfxSequenceDef;
      
      public var parameter:String;
      
      public var parameter_value:Number = 0;
      
      public var useBoardVfxLib:Boolean;
      
      public function PhantasmDefSprite(param1:Object, param2:ILogger)
      {
         super();
         EngineJsonDef.validateThrow(param1,schema,param2);
         PhantasmDefVars.parse(this,param1.base,param2);
         this.rotate = BooleanVars.parse(param1.rotate,this.rotate);
         this.color = param1.color != undefined ? uint(param1.color) : this.color;
         this.alpha = param1.alpha != undefined ? Number(param1.alpha) : this.alpha;
         this.height = param1.height != undefined ? Number(param1.height) : this.height;
         this.parameter = param1.parameter;
         this.parameter_value = NumberVars.parse(param1.parameter_value,this.parameter_value);
         this.useBoardVfxLib = param1.useBoardVfxLib;
         if(param1.vfx != undefined)
         {
            this.vfx = new VfxSequenceDef().fromJson(param1.vfx,param2);
         }
         else
         {
            if(param1.spriteName == undefined)
            {
               throw new ArgumentError("Needs a vfx or spriteName");
            }
            this.vfx = new VfxSequenceDef();
            this.vfx.id = param1.spriteName;
            this.vfx.start = param1.spriteName;
            this.vfx.alpha = this.alpha;
            this.vfx.color = this.color;
            if(param1.oriented)
            {
               this.vfx.oriented = param1.oriented;
            }
         }
      }
      
      override public function toJson() : Object
      {
         var _loc1_:Object = {"base":PhantasmDefVars.save(this)};
         if(this.vfx)
         {
            _loc1_.vfx = this.vfx.toJson();
         }
         if(this.parameter)
         {
            _loc1_.parameter = this.parameter;
         }
         if(this.parameter_value)
         {
            _loc1_.parameter_value = this.parameter_value;
         }
         if(this.rotate)
         {
            _loc1_.rotate = this.rotate;
         }
         if(this.color != 4294967295)
         {
            _loc1_.color = this.color;
         }
         if(this.alpha != 1)
         {
            _loc1_.alpha = this.alpha;
         }
         if(this.height != 0.5)
         {
            _loc1_.height = this.height;
         }
         if(this.useBoardVfxLib)
         {
            _loc1_.useBoardVfxLib = this.useBoardVfxLib;
         }
         return _loc1_;
      }
      
      override public function toString() : String
      {
         return "PDSprite " + super.toString() + " vfx=" + this.vfx + " rotate=" + this.rotate + " color=" + this.color + " alpha=" + this.alpha;
      }
   }
}

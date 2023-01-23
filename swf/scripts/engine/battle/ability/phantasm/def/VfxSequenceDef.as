package engine.battle.ability.phantasm.def
{
   import engine.core.logging.ILogger;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   import engine.def.NumberVars;
   import engine.def.PointVars;
   import engine.vfx.OrientedOffset;
   import engine.vfx.OrientedOffsetVars;
   import flash.geom.Point;
   
   public class VfxSequenceDef
   {
      
      public static const schema:Object = {
         "name":"VfxSequence",
         "type":"object",
         "properties":{
            "start":{"type":"string"},
            "loop":{"type":"string"},
            "end":{"type":"string"},
            "depth":{"type":"string"},
            "id":{"type":"string"},
            "delay":{
               "type":"number",
               "optional":true
            },
            "oriented":{
               "type":"boolean",
               "optional":true
            },
            "attach":{
               "type":"boolean",
               "optional":true
            },
            "blendMode":{
               "type":"string",
               "optional":true
            },
            "fadeIn":{
               "type":"boolean",
               "optional":true
            },
            "fadeOut":{
               "type":"boolean",
               "optional":true
            },
            "alpha":{
               "type":"number",
               "optional":true
            },
            "color":{
               "type":"string",
               "optional":true
            },
            "weight":{
               "type":"number",
               "optional":true
            },
            "always":{
               "type":"boolean",
               "optional":true
            },
            "randomize":{
               "type":"boolean",
               "optional":true
            },
            "offset":{
               "type":"string",
               "optional":true
            },
            "orientedOffset":{
               "type":OrientedOffsetVars.schema,
               "optional":true
            }
         }
      };
       
      
      public var id:String;
      
      public var start:String;
      
      public var loop:String;
      
      public var end:String;
      
      public var depth:String = "main0";
      
      public var delay:int;
      
      public var oriented:Boolean = false;
      
      public var attach:Boolean = false;
      
      public var blendMode:String;
      
      public var fadeOut:Boolean;
      
      public var fadeIn:Boolean;
      
      public var alpha:Number = 1;
      
      public var color:uint = 16777215;
      
      public var weight:Number = 1;
      
      public var always:Boolean;
      
      public var randomize:Boolean;
      
      public var offset:Point;
      
      public var orientedOffset:OrientedOffset;
      
      public function VfxSequenceDef()
      {
         super();
      }
      
      public static function vctor() : Vector.<VfxSequenceDef>
      {
         return new Vector.<VfxSequenceDef>();
      }
      
      public function clone() : VfxSequenceDef
      {
         return new VfxSequenceDef().fromJson(this.toJson(),null);
      }
      
      public function toString() : String
      {
         return "VfxSequenceDef [id=" + this.id + "]";
      }
      
      public function toJson() : Object
      {
         var _loc1_:Object = {
            "start":this.start,
            "loop":this.loop,
            "end":this.end,
            "depth":this.depth,
            "id":this.id
         };
         if(this.delay)
         {
            _loc1_.delay = this.delay;
         }
         if(this.oriented)
         {
            _loc1_.oriented = this.oriented;
         }
         if(this.attach)
         {
            _loc1_.attach = this.attach;
         }
         if(this.blendMode)
         {
            _loc1_.blendMode = this.blendMode;
         }
         if(this.fadeIn)
         {
            _loc1_.fadeIn = this.fadeIn;
         }
         if(this.fadeOut)
         {
            _loc1_.fadeOut = this.fadeOut;
         }
         if(this.alpha != 1)
         {
            _loc1_.apha = this.alpha;
         }
         if(this.color != 16777215)
         {
            _loc1_.color = this.color.toString(16);
         }
         if(this.weight != 1)
         {
            _loc1_.weight = this.weight;
         }
         if(this.always)
         {
            _loc1_.always = this.always;
         }
         if(this.randomize)
         {
            _loc1_.randomize = this.randomize;
         }
         if(Boolean(this.offset) && (Boolean(this.offset.x) || Boolean(this.offset.y)))
         {
            _loc1_.offset = PointVars.saveString(this.offset);
         }
         if(this.orientedOffset)
         {
            _loc1_.orientedOffset = OrientedOffsetVars.save(this.orientedOffset);
         }
         return _loc1_;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : VfxSequenceDef
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.id = param1.id;
         this.start = param1.start;
         this.loop = param1.loop;
         this.end = param1.end;
         this.depth = param1.depth;
         this.oriented = BooleanVars.parse(param1.oriented,this.oriented);
         this.attach = BooleanVars.parse(param1.attach,this.attach);
         this.blendMode = param1.blendMode;
         this.fadeIn = param1.fadeIn;
         this.fadeOut = param1.fadeOut;
         this.alpha = NumberVars.parse(param1.alpha,this.alpha);
         if(param1.color)
         {
            this.color = uint(param1.color);
         }
         this.delay = param1.delay;
         this.weight = NumberVars.parse(param1.weight,this.weight);
         this.randomize = param1.randomize;
         this.always = param1.always;
         this.offset = PointVars.parseString(param1.offset,null);
         if(param1.orientedOffset)
         {
            this.orientedOffset = new OrientedOffsetVars().fromJson(param1.orientedOffset,null);
         }
         return this;
      }
   }
}

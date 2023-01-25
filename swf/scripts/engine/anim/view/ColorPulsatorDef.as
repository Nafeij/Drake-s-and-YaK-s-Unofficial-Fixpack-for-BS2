package engine.anim.view
{
   import engine.core.logging.ILogger;
   import engine.core.util.ColorUtil;
   import engine.def.EngineJsonDef;
   import engine.math.MathUtil;
   
   public class ColorPulsatorDef
   {
      
      public static const schema:Object = {
         "name":"ColorPulsatorDef",
         "type":"object",
         "properties":{
            "id":{
               "type":"string",
               "optional":true
            },
            "color_a":{
               "type":"string",
               "optional":true
            },
            "color_b":{
               "type":"string",
               "optional":true
            },
            "alpha_a":{
               "type":"number",
               "optional":true
            },
            "alpha_b":{
               "type":"number",
               "optional":true
            },
            "cycles":{
               "type":"number",
               "optional":true
            },
            "periodMs":{"type":"number"},
            "exponent":{"type":"number"}
         }
      };
       
      
      public var id:String;
      
      public var a:uint = 4294967295;
      
      public var b:uint = 4294967295;
      
      public var alpha_a8:int = 255;
      
      public var alpha_b8:int = 255;
      
      public var periodMs:int = 0;
      
      public var exponent:int = 1;
      
      public var cycles:Number = 0;
      
      public var hasColor:Boolean;
      
      public function ColorPulsatorDef()
      {
         super();
      }
      
      public function toString() : String
      {
         return this.id + " " + this.a.toString(16) + " -> " + this.b.toString(16) + " in " + this.periodMs;
      }
      
      public function computeColor(param1:int) : uint
      {
         var _loc4_:uint = 0;
         var _loc5_:Number = NaN;
         var _loc2_:Number = param1 / this.periodMs;
         if(this.cycles > 0)
         {
            _loc2_ = Math.min(_loc2_,this.cycles);
         }
         _loc2_ *= MathUtil.PI_TIMES_2;
         var _loc3_:Number = -Math.cos(_loc2_) * 0.5 + 0.5;
         if(this.exponent == 2)
         {
            _loc3_ *= _loc3_;
         }
         else if(this.exponent > 2)
         {
            _loc3_ *= _loc3_ * _loc3_;
         }
         if(!this.hasColor)
         {
            _loc4_ = MathUtil.lerp(this.alpha_a8,this.alpha_b8,_loc3_);
            _loc4_ &= 255;
            _loc4_ <<= 24;
         }
         else
         {
            _loc4_ = ColorUtil.lerpColor(this.a,this.b,_loc3_);
         }
         if(param1 < this.periodMs)
         {
            _loc5_ = param1 / this.periodMs;
            if(this.a != 4294967295)
            {
               if(!this.hasColor)
               {
                  _loc4_ = MathUtil.lerp(255,_loc4_ >> 24 & 255,_loc5_);
                  _loc4_ &= 255;
                  _loc4_ <<= 24;
                  _loc4_ |= 16777215;
               }
               else
               {
                  _loc4_ = ColorUtil.lerpColor(4294967295,_loc4_,_loc5_);
               }
            }
         }
         return _loc4_;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : ColorPulsatorDef
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.id = param1.id;
         if(param1.color_a != undefined)
         {
            this.a = uint(param1.color_a);
         }
         if(param1.color_b != undefined)
         {
            this.b = uint(param1.color_b);
         }
         var _loc3_:Number = 1;
         var _loc4_:Number = 1;
         if(param1.alpha_a != undefined)
         {
            _loc3_ = Number(param1.alpha_a);
         }
         if(param1.alpha_b != undefined)
         {
            _loc4_ = Number(param1.alpha_b);
         }
         this.alpha_a8 = _loc3_ * 255;
         this.alpha_b8 = _loc4_ * 255;
         this.a &= ~4278190080;
         this.b &= ~4278190080;
         this.hasColor = this.a != this.b;
         this.a |= uint(_loc3_ * 255) << 24;
         this.b |= uint(_loc4_ * 255) << 24;
         if(param1.cycles != undefined)
         {
            this.cycles = param1.cycles;
         }
         this.periodMs = param1.periodMs;
         this.exponent = param1.exponent;
         return this;
      }
      
      public function toJson() : Object
      {
         var _loc1_:uint = uint(this.a >> 24 & 255);
         var _loc2_:uint = uint(this.b >> 24 & 255);
         var _loc3_:Object = {
            "periodMs":this.periodMs,
            "exponent":this.exponent
         };
         if(this.id)
         {
            _loc3_.id = this.id;
         }
         if((this.a & 16777215) != 16777215)
         {
            _loc3_.color_a = this.a.toString(16);
         }
         if((this.b & 16777215) != 16777215)
         {
            _loc3_.color_b = this.b.toString(16);
         }
         if(_loc1_ != 255)
         {
            _loc3_.alpha_a = _loc1_ / 255;
         }
         if(_loc2_ != 255)
         {
            _loc3_.alpha_b = _loc2_ / 255;
         }
         return _loc3_;
      }
   }
}

package engine.battle.ability.phantasm.def
{
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.def.EngineJsonDef;
   
   public class PhantasmDefFlyText extends PhantasmDef
   {
      
      public static const schema:Object = {
         "name":"PhantasmDefFlyText",
         "description":"PhantasmDefFlyText Definition",
         "type":"object",
         "properties":{
            "message":{
               "type":"string",
               "description":"the encoded message"
            },
            "color":{
               "type":"number",
               "description":"the color to display"
            },
            "fontName":{
               "type":"string",
               "description":"the font name"
            },
            "fontSize":{
               "type":"number",
               "description":"the font size"
            },
            "base":{"type":PhantasmDefVars.schema}
         }
      };
       
      
      public var message:String;
      
      public var color:uint;
      
      public var fontName:String;
      
      public var fontSize:int;
      
      public var tokens:Array;
      
      public function PhantasmDefFlyText(param1:Object, param2:ILogger)
      {
         var _loc6_:Boolean = false;
         var _loc7_:TextToken = null;
         var _loc8_:int = 0;
         var _loc9_:String = null;
         var _loc10_:TextOpVar = null;
         var _loc11_:String = null;
         this.tokens = new Array();
         super();
         EngineJsonDef.validateThrow(param1,schema,param2);
         PhantasmDefVars.parse(this,param1.base,param2);
         this.message = param1.message;
         this.color = param1.color;
         this.fontName = param1.fontName;
         this.fontSize = param1.fontSize;
         var _loc3_:Vector.<Enum> = Enum.getVector(TextToken);
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         while(true)
         {
            _loc5_ = this.message.indexOf("%",_loc4_);
            if(_loc5_ < 0)
            {
               this.tokens.push(this.message.substring(_loc4_));
               break;
            }
            if(this.message.charAt(_loc5_ + 1) == "%")
            {
               this.tokens.push(this.message.substring(_loc4_,_loc5_ + 1));
               _loc4_ = _loc5_ + 2;
            }
            else
            {
               if(_loc5_ > _loc4_)
               {
                  this.tokens.push(this.message.substring(_loc4_,_loc5_));
               }
               _loc6_ = false;
               for each(_loc7_ in _loc3_)
               {
                  if(this.message.indexOf(_loc7_.token,_loc5_ + 1) == _loc5_ + 1)
                  {
                     _loc4_ = _loc5_ + 1 + _loc7_.token.length;
                     if(_loc7_ == TextToken.OPVAR)
                     {
                        if(this.message.charAt(_loc4_) == "{")
                        {
                           _loc4_++;
                           _loc8_ = this.message.indexOf("}",_loc4_);
                           _loc9_ = this.message.substring(_loc4_,_loc8_);
                           _loc10_ = new TextOpVar(_loc9_);
                           _loc4_ = _loc8_ + 1;
                           this.tokens.push(_loc10_);
                        }
                        else
                        {
                           param2.error("wtf " + this.message.substring(_loc4_));
                        }
                     }
                     else
                     {
                        this.tokens.push(_loc7_);
                     }
                     _loc6_ = true;
                     break;
                  }
               }
               if(!_loc6_)
               {
                  _loc11_ = this.message.substring(_loc5_);
                  param2.error("invalid token: [" + _loc11_ + "]");
                  this.tokens.push(_loc11_);
                  break;
               }
            }
         }
      }
      
      override public function toString() : String
      {
         return "PDFlyText " + super.toString() + " color=" + this.color + " fontName=" + this.fontName + " fontSize=" + this.fontSize + " message=" + this.message;
      }
      
      override public function toJson() : Object
      {
         return {
            "message":this.message,
            "color":this.color,
            "fontName":this.fontName,
            "fontSize":this.fontSize,
            "base":PhantasmDefVars.save(this)
         };
      }
   }
}

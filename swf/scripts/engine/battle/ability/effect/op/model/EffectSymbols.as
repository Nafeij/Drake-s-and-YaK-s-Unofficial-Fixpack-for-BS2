package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.effect.model.IEffect;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.util.Enum;
   import engine.expression.ISymbols;
   import engine.expression.Symbols;
   import engine.stat.def.StatType;
   import flash.utils.Dictionary;
   
   public class EffectSymbols implements ISymbols
   {
       
      
      public var effect:IEffect;
      
      private var _added:Dictionary;
      
      private var symbols:ISymbols;
      
      public function EffectSymbols(param1:IEffect)
      {
         super();
         this.effect = param1;
         this.symbols = param1.symbols;
      }
      
      public function addSymbol(param1:String, param2:Number) : void
      {
         if(!this._added)
         {
            this._added = new Dictionary();
         }
         this._added[param1] = param2;
      }
      
      public function replaceSymbols(param1:String) : String
      {
         var dolla:int = 0;
         var toki:int = 0;
         var toklen:int = 0;
         var tok:String = null;
         var vv:Number = NaN;
         var vs:String = null;
         var msg:String = param1;
         dolla = msg.indexOf("${");
         while(dolla > 0)
         {
            toki = msg.indexOf("}",dolla);
            if(toki > dolla)
            {
               toklen = toki - (dolla + 2);
               tok = msg.substr(dolla + 2,toklen);
               if(tok)
               {
                  try
                  {
                     vv = this.getSymbolValue(tok,true);
                     vs = vv.toFixed(0);
                     msg = msg.substring(0,dolla) + vs + msg.substring(toki + 1);
                     dolla += vs.length;
                  }
                  catch(e:Error)
                  {
                     dolla += tok.length;
                  }
               }
            }
            else
            {
               dolla += 2;
            }
            dolla = msg.indexOf("${",dolla);
         }
         return msg;
      }
      
      public function getSymbolValue(param1:String, param2:Boolean) : Number
      {
         var _loc6_:IBattleEntity = null;
         var _loc9_:* = undefined;
         if(this._added)
         {
            _loc9_ = this._added[param1];
            if(_loc9_ != undefined)
            {
               return Symbols.process(_loc9_);
            }
         }
         var _loc3_:Array = param1.split(".");
         if(_loc3_.length != 2)
         {
            throw new ArgumentError("Invalid format for symbol [" + param1 + "], expected [a.b]");
         }
         var _loc4_:String = String(_loc3_[0]);
         _loc4_ = _loc4_.toLowerCase();
         var _loc5_:String = String(_loc3_[1]);
         if(_loc4_ == "saga")
         {
            if(!this.symbols)
            {
               throw new ArgumentError("no symbols");
            }
            return this.symbols.getSymbolValue(_loc5_,param2);
         }
         switch(_loc4_)
         {
            case "target":
               _loc6_ = this.effect.target;
               break;
            case "caster":
            case "self":
               _loc6_ = this.effect.ability.caster;
         }
         if(!_loc6_)
         {
            throw new ArgumentError("Unknown prefix [" + _loc4_ + "] for symbol [" + param1 + "], expected {target,caster,self}");
         }
         var _loc7_:String = _loc5_.toUpperCase();
         var _loc8_:StatType = Enum.parse(StatType,_loc7_,false,null) as StatType;
         if(_loc8_)
         {
            return _loc6_.stats.getValue(_loc8_);
         }
         throw new ArgumentError("Unknown suffix [" + _loc5_ + "] for symbol [" + param1 + "], expected stat type");
      }
   }
}

package engine.battle.board.view.phantasm
{
   import engine.battle.ability.effect.op.model.Op;
   import engine.battle.ability.phantasm.def.PhantasmDefFlyText;
   import engine.battle.ability.phantasm.def.PhantasmTargetMode;
   import engine.battle.ability.phantasm.def.TextOpVar;
   import engine.battle.ability.phantasm.def.TextToken;
   import engine.battle.ability.phantasm.model.ChainPhantasms;
   import engine.battle.board.view.BattleBoardView;
   import engine.core.locale.Locale;
   import engine.core.util.StringUtil;
   
   public class PhantasmViewFlyText extends PhantasmView
   {
       
      
      private var defFlyText:PhantasmDefFlyText;
      
      public function PhantasmViewFlyText(param1:BattleBoardView, param2:ChainPhantasms, param3:PhantasmDefFlyText)
      {
         super(param1,param2,param3);
         this.defFlyText = param3;
      }
      
      override public function execute() : void
      {
         super.execute();
         var _loc1_:String = this.decodeFlyText();
         switch(def.targetMode)
         {
            case PhantasmTargetMode.CASTER:
               chain.effect.ability.caster.emitFlyText(_loc1_,this.defFlyText.color,this.defFlyText.fontName,this.defFlyText.fontSize);
               break;
            case PhantasmTargetMode.TARGET:
               if(chain.effect.target)
               {
                  chain.effect.target.emitFlyText(_loc1_,this.defFlyText.color,this.defFlyText.fontName,this.defFlyText.fontSize);
               }
               break;
            case PhantasmTargetMode.TILE:
               if(chain.effect.tile)
               {
                  boardView.board.tiles.emitFlyText(chain.effect.tile,_loc1_,this.defFlyText.color,this.defFlyText.fontName,this.defFlyText.fontSize);
               }
         }
      }
      
      private function decodeFlyText() : String
      {
         var _loc3_:* = undefined;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:TextToken = null;
         var _loc7_:TextOpVar = null;
         var _loc8_:Op = null;
         var _loc9_:* = undefined;
         var _loc1_:String = "";
         var _loc2_:Locale = boardView.board.scene.context.locale;
         for each(_loc3_ in this.defFlyText.tokens)
         {
            if(_loc3_ is String)
            {
               _loc4_ = _loc3_ as String;
               if(Boolean(_loc4_) && StringUtil.startsWith(_loc4_,"$"))
               {
                  _loc5_ = _loc2_.translateEncodedToken(_loc4_.substr(1),false);
                  _loc1_ += _loc5_;
               }
               else
               {
                  _loc1_ += _loc3_;
               }
            }
            else if(_loc3_ is TextToken)
            {
               _loc6_ = _loc3_;
               switch(_loc6_)
               {
                  case TextToken.ABILITY_NAME:
                     _loc1_ += chain.effect.ability.def.name;
                     break;
                  case TextToken.CASTER_NAME:
                     _loc1_ += chain.effect.ability.caster.name;
                     break;
                  case TextToken.TARGET_NAME:
                     if(chain.effect.target != null)
                     {
                        _loc1_ += chain.effect.target.name;
                     }
               }
            }
            else if(_loc3_ is TextOpVar)
            {
               _loc7_ = _loc3_ as TextOpVar;
               boardView.board.logger.debug("PhantasmViewFlyText custom: " + _loc7_.path);
               _loc8_ = chain.effect.getOpByName(_loc7_.opName);
               _loc9_ = _loc8_[_loc7_.opVar];
               _loc1_ += _loc9_;
            }
            else
            {
               boardView.board.logger.error("fail!?!AD ok");
            }
         }
         return _loc1_;
      }
   }
}

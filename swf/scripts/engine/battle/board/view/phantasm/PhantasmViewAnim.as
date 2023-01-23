package engine.battle.board.view.phantasm
{
   import engine.anim.def.IAnimLibrary;
   import engine.anim.view.AnimController;
   import engine.battle.ability.effect.model.EffectTag;
   import engine.battle.ability.phantasm.def.PhantasmDefAnim;
   import engine.battle.ability.phantasm.def.PhantasmTargetMode;
   import engine.battle.ability.phantasm.model.ChainPhantasms;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.entity.model.BattleEntity;
   import engine.battle.entity.view.EntityView;
   
   public class PhantasmViewAnim extends PhantasmView
   {
       
      
      private var defAnim:PhantasmDefAnim;
      
      private var entityView:EntityView;
      
      public function PhantasmViewAnim(param1:BattleBoardView, param2:ChainPhantasms, param3:PhantasmDefAnim)
      {
         super(param1,param2,param3);
         this.defAnim = param3;
      }
      
      override public function execute() : void
      {
         var _loc2_:EntityView = null;
         var _loc3_:AnimController = null;
         var _loc4_:EntityView = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:AnimController = null;
         var _loc8_:IAnimLibrary = null;
         var _loc9_:* = null;
         super.execute();
         var _loc1_:BattleEntity = chain.effect.target as BattleEntity;
         switch(def.targetMode)
         {
            case PhantasmTargetMode.CASTER:
               _loc2_ = boardView.getEntityView(chain.effect.ability.caster as BattleEntity);
               _loc3_ = _loc2_.animSprite.controller;
               if(this.defAnim.noloco)
               {
                  if(Boolean(_loc2_.entity.mobility) && _loc2_.entity.mobility.moving)
                  {
                     return;
                  }
               }
               if(this.defAnim.freeze)
               {
                  _loc3_.ignoreFreezeFrame = false;
               }
               else if(this.defAnim.unfreeze)
               {
                  _loc3_.ignoreFreezeFrame = true;
                  if(_loc3_.current)
                  {
                     _loc3_.current.frozen = false;
                  }
               }
               if(this.defAnim.ambient)
               {
                  _loc3_.ambientMix = !!this.defAnim.anim ? this.defAnim.anim : "mix_idle";
                  return;
               }
               if(this.defAnim.anim)
               {
                  if(Boolean(_loc2_.animSprite) && Boolean(_loc3_))
                  {
                     if(_loc3_.currentPriority > this.defAnim.priority)
                     {
                        logger.info("PhantasmViewAnim TARGET " + _loc2_ + " " + this.defAnim + " lower priority than " + _loc3_);
                        return;
                     }
                  }
                  _loc3_.playAnim(this.defAnim.anim,1,false,true,this.defAnim.reverse,1,null,this.defAnim.priority);
               }
               break;
            case PhantasmTargetMode.TARGET:
               if(chain.effect.target)
               {
                  _loc4_ = boardView.getEntityView(chain.effect.target as BattleEntity);
                  if(this.defAnim.noloco)
                  {
                     if(Boolean(_loc4_.entity.mobility) && _loc4_.entity.mobility.moving)
                     {
                        return;
                     }
                  }
                  if(this.defAnim.freeze)
                  {
                     _loc7_.ignoreFreezeFrame = false;
                  }
                  else if(this.defAnim.unfreeze)
                  {
                     _loc7_.ignoreFreezeFrame = true;
                     _loc7_.current.frozen = false;
                  }
                  if(this.defAnim.ambient)
                  {
                     _loc4_.animSprite.controller.ambientMix = !!this.defAnim.anim ? this.defAnim.anim : "mix_idle";
                     return;
                  }
                  if(chain.effect.hasTag(EffectTag.KILLING) && this.defAnim.killingAnim && !_loc4_.playedDeathAnim)
                  {
                     _loc5_ = !!_loc1_ ? _loc1_.deathVocalization : null;
                     _loc4_.playDeathAnim(this.defAnim.killingAnim,_loc5_);
                  }
                  else if(!_loc4_.playedDeathAnim)
                  {
                     if(Boolean(_loc4_.animSprite) && Boolean(_loc4_.animSprite.controller))
                     {
                        if(_loc4_.animSprite.controller.currentPriority > this.defAnim.priority)
                        {
                           logger.info("PhantasmViewAnim TARGET " + _loc4_ + " " + this.defAnim + " lower priority than " + _loc4_.animSprite.controller);
                           return;
                        }
                     }
                     _loc6_ = this.defAnim.anim;
                     if(_loc6_)
                     {
                        _loc7_ = _loc4_.animSprite.controller;
                        if(chain.effect.hasTag(EffectTag.ARMOR_ZEROING))
                        {
                           _loc8_ = _loc7_.library;
                           _loc9_ = _loc6_ + "_shieldbreak";
                           if(Boolean(_loc8_) && _loc8_.hasOrientedAnims(_loc7_.layer,_loc9_))
                           {
                              _loc6_ = _loc9_;
                           }
                        }
                        _loc7_.playAnim(_loc6_,1,false,true,this.defAnim.reverse,1,null,this.defAnim.priority);
                     }
                  }
               }
               break;
            case PhantasmTargetMode.TILE:
               throw new ArgumentError("fail gravy -- tile anim?  puleeeze");
         }
      }
   }
}

package engine.battle.ability.effect.op.model
{
   import engine.anim.event.AnimControllerEvent;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityTargetRule;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.board.model.IBattleEntity;
   import engine.def.BooleanVars;
   import engine.def.StringVars;
   import engine.tile.Tile;
   import engine.tile.def.TileRect;
   import flash.utils.Dictionary;
   
   public class Op_RunThrough extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_RunThrough",
         "properties":{
            "ability_final":{
               "type":"string",
               "optional":true
            },
            "ability_intersect":{
               "type":"string",
               "optional":true
            },
            "move_to_front":{
               "type":"boolean",
               "optional":true
            },
            "return_to_origin":{
               "type":"boolean",
               "optional":true
            },
            "loco_anim_to":{
               "type":"string",
               "optional":true
            },
            "loco_anim_return":{
               "type":"string",
               "optional":true
            },
            "loco_suppress_facing_to":{
               "type":"boolean",
               "optional":true
            },
            "loco_suppress_facing_return":{
               "type":"boolean",
               "optional":true
            },
            "anim_return_complete":{
               "type":"string",
               "optional":true
            },
            "is_teleporting":{
               "type":"boolean",
               "optional":true
            },
            "damage_on_intersect":{
               "type":"boolean",
               "optional":true
            },
            "intersect_anim":{
               "type":"string",
               "optional":true
            }
         }
      };
       
      
      private const _LOCO_ID:String = "ability_run";
      
      private var originX:int;
      
      private var originY:int;
      
      private var destinationX:int;
      
      private var destinationY:int;
      
      private var ram_to:RunAxisMediator;
      
      private var ram_return:RunAxisMediator;
      
      private var alreadyHits:Dictionary;
      
      private var move_to_front:Boolean;
      
      private var return_to_origin:Boolean;
      
      private var abl_id_final:String = "abl_runthrough_final_attack";
      
      private var abl_id_intersect:String = "abl_runthrough_arm_dam";
      
      private var loco_anim_to:String = "ability_run";
      
      private var loco_anim_return:String = "ability_run";
      
      private var anim_return_complete:String = null;
      
      private var loco_suppress_facing_to:Boolean;
      
      private var loco_suppress_facing_return:Boolean;
      
      private var _isTeleporting:Boolean = false;
      
      private var _previousIndicatorState:Boolean = true;
      
      private var _previousTeleportingState:Boolean = false;
      
      private var _intersectingAnim:String = null;
      
      private var _damageOnIntersect:Boolean = true;
      
      public function Op_RunThrough(param1:EffectDefOp, param2:Effect)
      {
         this.alreadyHits = new Dictionary();
         var _loc3_:Object = param1.params;
         this.abl_id_final = StringVars.parse(_loc3_.ability_final,this.abl_id_final);
         this.abl_id_intersect = StringVars.parse(_loc3_.ability_intersect,this.abl_id_intersect);
         this.loco_anim_to = StringVars.parse(_loc3_.loco_anim_to,this.loco_anim_to);
         this.loco_anim_return = StringVars.parse(_loc3_.loco_anim_return,this.loco_anim_return);
         this.anim_return_complete = StringVars.parse(_loc3_.anim_return_complete,this.anim_return_complete);
         this.loco_suppress_facing_to = BooleanVars.parse(_loc3_.loco_suppress_facing_to,this.loco_suppress_facing_to);
         this.loco_suppress_facing_return = BooleanVars.parse(_loc3_.loco_suppress_facing_return,this.loco_suppress_facing_return);
         this.move_to_front = BooleanVars.parse(_loc3_.move_to_front,this.move_to_front);
         this.return_to_origin = BooleanVars.parse(_loc3_.return_to_origin,this.return_to_origin);
         this._isTeleporting = BooleanVars.parse(_loc3_.is_teleporting,this._isTeleporting);
         this._intersectingAnim = StringVars.parse(_loc3_.intersect_anim,this._intersectingAnim);
         this._damageOnIntersect = BooleanVars.parse(_loc3_.damage_on_intersect,this._damageOnIntersect);
         super(param1,param2);
         manager.factory.fetchBattleAbilityDef(this.abl_id_final);
         manager.factory.fetchBattleAbilityDef(this.abl_id_intersect);
      }
      
      override public function execute() : EffectResult
      {
         var _loc4_:Tile = null;
         var _loc1_:TileRect = target.rect;
         var _loc2_:* = ability.def.targetRule != BattleAbilityTargetRule.SPECIAL_TRAMPLE;
         var _loc3_:TileRect = caster.rect;
         if(this.move_to_front)
         {
            _loc4_ = Op_RunThroughHelper.findLandingTileBefore(caster,_loc3_,_loc1_,_loc2_);
         }
         else
         {
            _loc4_ = Op_RunThroughHelper.findLandingTileBehind(caster,_loc3_,_loc1_,_loc2_);
         }
         if(_loc4_ != null)
         {
            if(!_loc3_.contains(_loc4_.x,_loc4_.y))
            {
               this.originX = _loc3_.loc.x;
               this.originY = _loc3_.loc.y;
               this.destinationX = _loc4_.x;
               this.destinationY = _loc4_.y;
               return EffectResult.OK;
            }
         }
         return EffectResult.FAIL;
      }
      
      override public function apply() : void
      {
         if(ability.fake || manager.faking)
         {
            return;
         }
         effect.blockComplete();
         caster.incrementIgnoreTargetRotation();
         this._previousTeleportingState = caster.isTeleporting;
         this._previousIndicatorState = caster.battleHudIndicatorVisible;
         this.setTeleportationState(true);
         this.ram_to = new RunAxisMediator(caster,target,this.destinationX,this.destinationY,this.loco_anim_to,!this.loco_suppress_facing_to,logger,this.handleRamExecuted_to,this.handleRamInterrupted_to,this.handleRamIntersected_to,this._intersectingAnim != null);
         this.ram_to.start();
      }
      
      private function setTeleportationState(param1:Boolean) : void
      {
         caster.battleHudIndicatorVisible = param1 ? !this._isTeleporting : this._previousIndicatorState;
         caster.isTeleporting = param1 ? this._isTeleporting : this._previousTeleportingState;
      }
      
      private function handleRamExecuted_to(param1:RunAxisMediator) : void
      {
         if(board.fsm.turn && board.fsm.turn.suspended || !caster.alive)
         {
            effect.unblockComplete();
            return;
         }
         var _loc2_:BattleAbilityDef = manager.factory.fetchBattleAbilityDef(this.abl_id_final);
         var _loc3_:BattleAbility = new BattleAbility(caster,_loc2_,manager);
         _loc3_.targetSet.setTarget(target);
         ability.addChildAbilityCallback(_loc3_,this.handleAbilityExecuted);
      }
      
      private function handleRamInterrupted_to(param1:RunAxisMediator) : void
      {
         this.setTeleportationState(false);
         effect.unblockComplete();
      }
      
      private function handleRamIntersected_to(param1:RunAxisMediator, param2:IBattleEntity) : void
      {
         this.setTeleportationState(false);
         if(this._damageOnIntersect)
         {
            this.handleIntersectingAbility(param2);
         }
         if(this._intersectingAnim)
         {
            caster.animController.addEventListener(AnimControllerEvent.FINISHING,this.handleIntersectingAnimComplete);
            caster.animController.playAnim(this.anim_return_complete,1);
         }
         else
         {
            effect.unblockComplete();
         }
      }
      
      private function handleIntersectingAnimComplete(param1:AnimControllerEvent) : void
      {
         caster.animController.removeEventListener(AnimControllerEvent.FINISHING,this.handleIntersectingAnimComplete);
         effect.unblockComplete();
      }
      
      private function handleIntersectingAbility(param1:IBattleEntity) : void
      {
         if(!param1)
         {
            return;
         }
         if(!param1.alive || caster == param1 || !param1.attackable)
         {
            return;
         }
         if(this.alreadyHits[param1])
         {
            caster.logger.info("Op_RunThrough.handleIntersectingAbility SKIPPING " + param1 + ", already hit");
            return;
         }
         this.alreadyHits[param1] = param1;
         var _loc2_:BattleAbilityDef = manager.factory.fetchBattleAbilityDef(this.abl_id_intersect);
         var _loc3_:BattleAbility = new BattleAbility(caster,_loc2_,manager);
         _loc3_.targetSet.setTarget(param1);
         ability.addChildAbilityCallback(_loc3_,null);
      }
      
      private function handleAbilityExecuted(param1:BattleAbility) : void
      {
         if(!this.return_to_origin || !caster.alive)
         {
            effect.unblockComplete();
            return;
         }
         this.setTeleportationState(true);
         this.ram_return = new RunAxisMediator(caster,null,this.originX,this.originY,this.loco_anim_return,!this.loco_suppress_facing_return,logger,this.handleRamExecuted_return,this.handleRamInterrupted_return,this.handleRamIntersected_return);
         this.ram_return.start();
      }
      
      private function handleRamExecuted_return(param1:RunAxisMediator) : void
      {
         if(this.anim_return_complete)
         {
            caster.animController.addEventListener(AnimControllerEvent.FINISHING,this.onAnimReturnComplete);
            caster.animController.playAnim(this.anim_return_complete,1);
         }
         else
         {
            effect.unblockComplete();
         }
      }
      
      private function onAnimReturnComplete(param1:AnimControllerEvent) : void
      {
         caster.animController.removeEventListener(AnimControllerEvent.FINISHING,this.onAnimReturnComplete);
         effect.unblockComplete();
      }
      
      private function handleRamInterrupted_return(param1:RunAxisMediator) : void
      {
         effect.unblockComplete();
      }
      
      private function handleRamIntersected_return(param1:RunAxisMediator, param2:IBattleEntity) : void
      {
      }
      
      override public function remove() : void
      {
         caster.decrementIgnoreTargetRotation();
         this.setTeleportationState(false);
         if(this.ram_to)
         {
            this.ram_to.cleanup();
            this.ram_to = null;
         }
         if(this.ram_return)
         {
            this.ram_return.cleanup();
            this.ram_return = null;
         }
      }
   }
}

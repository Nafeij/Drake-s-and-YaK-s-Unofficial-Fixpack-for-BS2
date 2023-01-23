package game.gui.page
{
   import engine.ability.IAbilityDef;
   import engine.ability.def.AbilityDefLevel;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityDefLevels;
   import engine.battle.ability.def.BattleAbilityTag;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.StatChangeData;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleFsmEvent;
   import engine.battle.fsm.BattleTurn;
   import engine.core.gp.GpControlButton;
   import engine.gui.BattleHudConfig;
   import engine.stat.def.StatType;
   import game.gui.BattleHudDamageHelper;
   import game.gui.battle.IGuiEnemyPopup;
   
   public class PopupEnemyHelper extends PopupHelper
   {
       
      
      private var popupEnemy:IGuiEnemyPopup;
      
      private var armSetup:Array;
      
      private var strSetup:Array;
      
      private var fsm:BattleFsm;
      
      public function PopupEnemyHelper(param1:IGuiEnemyPopup, param2:BattleBoardView, param3:BattleHudConfig)
      {
         this.armSetup = new Array();
         this.strSetup = new Array();
         super(param1,param2,param3);
         this.popupEnemy = param1;
         this.fsm = param2.board.sim.fsm;
         this.fsm.addEventListener(BattleFsmEvent.TURN_ABILITY,this.turnAbilityHandler);
      }
      
      override public function cleanup() : void
      {
         this.fsm.removeEventListener(BattleFsmEvent.TURN_ABILITY,this.turnAbilityHandler);
         this.fsm = null;
         super.cleanup();
      }
      
      public function handleConfirm() : Boolean
      {
         return Boolean(this.popupEnemy) && Boolean(this.popupEnemy.handleConfirm());
      }
      
      private function checkPopup(param1:BattleTurn) : Boolean
      {
         if(!enabled)
         {
            return false;
         }
         if(!param1)
         {
            return false;
         }
         if(param1.committed)
         {
            return false;
         }
         if(param1.move.executing)
         {
            return false;
         }
         var _loc2_:* = param1._numAbilities == 0;
         if(!_loc2_)
         {
            return false;
         }
         if(!param1.turnInteract)
         {
            return false;
         }
         if(!param1.entity.playerControlled)
         {
            return false;
         }
         if(param1.turnInteract.party == param1.entity.party)
         {
            return false;
         }
         if(param1.ability)
         {
            return false;
         }
         var _loc3_:IBattleBoard = param1.entity.board;
         if(!_loc3_ || _loc3_.isUsingEntity)
         {
            return false;
         }
         return true;
      }
      
      public function setupPopup(param1:BattleTurn) : void
      {
         var _loc2_:BattleAbilityDefLevels = null;
         var _loc3_:IBattleEntity = null;
         var _loc4_:IBattleEntity = null;
         var _loc5_:int = 0;
         var _loc6_:StatChangeData = null;
         var _loc7_:Boolean = false;
         var _loc8_:Boolean = false;
         var _loc9_:int = 0;
         var _loc10_:Vector.<AbilityDefLevel> = null;
         var _loc11_:Vector.<AbilityDefLevel> = null;
         var _loc12_:AbilityDefLevel = null;
         var _loc13_:BattleAbilityDef = null;
         var _loc14_:int = 0;
         var _loc15_:BattleAbilityDef = null;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc18_:* = null;
         if(!this.checkPopup(param1) || !battleHudConfig.enemyPopup)
         {
            this.popupEnemy.entity = null;
         }
         else
         {
            if(this.popupEnemy.entity == param1.turnInteract)
            {
               return;
            }
            _loc2_ = param1.entity.def.attacks as BattleAbilityDefLevels;
            _loc3_ = param1.entity;
            _loc4_ = param1.turnInteract;
            if(!_loc3_)
            {
               return;
            }
            if(!_loc3_.awareOf(_loc4_))
            {
               this.popupEnemy.entity = null;
               return;
            }
            this.popupEnemy.entity = param1.turnInteract;
            _loc5_ = BattleHudPage.calculateRemainingTurnMaxStars(param1);
            _loc6_ = new StatChangeData();
            _loc7_ = false;
            _loc8_ = false;
            _loc9_ = 0;
            _loc10_ = _loc2_.getAbilityDefLevelsByTag(BattleAbilityTag.ATTACK_STR);
            _loc11_ = _loc2_.getAbilityDefLevelsByTag(BattleAbilityTag.ATTACK_ARM);
            for each(_loc12_ in _loc10_)
            {
               _loc13_ = _loc12_.def as BattleAbilityDef;
               if(BattleAbility.getStatChange(_loc13_,_loc3_,StatType.STRENGTH,_loc6_,_loc4_,null))
               {
                  if(_loc6_.amount >= 0)
                  {
                     _loc7_ = true;
                     _loc14_ = BattleHudDamageHelper.strengthNormalDamage(param1.entity,param1.turnInteract);
                     this.strSetup[0] = _loc13_.id;
                     this.strSetup[1] = _loc14_;
                     this.strSetup[2] = _loc6_.amount;
                     _loc9_ = _loc6_.missChance;
                     break;
                  }
               }
            }
            if(!_loc7_)
            {
               this.strSetup[0] = null;
               this.strSetup[1] = 0;
               this.strSetup[2] = 0;
            }
            for each(_loc12_ in _loc11_)
            {
               _loc15_ = _loc12_.def as BattleAbilityDef;
               if(BattleAbility.getStatChange(_loc15_ as BattleAbilityDef,param1.entity,StatType.ARMOR,_loc6_,param1.turnInteract,null))
               {
                  _loc8_ = true;
                  _loc16_ = BattleHudDamageHelper.armorNormalDamage(param1.entity,param1.turnInteract);
                  this.armSetup[0] = _loc15_.id;
                  this.armSetup[1] = _loc16_;
                  this.armSetup[2] = _loc6_.amount;
               }
            }
            if(!_loc8_)
            {
               this.armSetup[0] = null;
               this.armSetup[1] = 0;
               this.armSetup[2] = 0;
            }
            if(!_loc8_ && !_loc7_)
            {
               this.popupEnemy.entity = null;
            }
            else
            {
               _loc17_ = 0;
               for(_loc18_ in param1._inRange)
               {
                  _loc17_++;
               }
               this.popupEnemy.setupPopup(this.armSetup,this.strSetup,_loc9_,_loc5_,_loc17_);
               positionPopup();
            }
         }
      }
      
      public function updateWillpower(param1:int) : void
      {
         this.popupEnemy.updateWillpower(param1);
      }
      
      public function selectAbility(param1:BattleTurn, param2:String, param3:int) : Boolean
      {
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         if(param2 == null)
         {
            throw new ArgumentError("Popup select null ability id");
         }
         var _loc4_:int = BattleHudPage.calculateRemainingTurnMaxStars(param1);
         if(param3 > _loc4_)
         {
            throw new ArgumentError("Popup Select cannot choose " + param3 + " when max is " + _loc4_);
         }
         var _loc5_:IAbilityDef = param1.entity.def.attacks.getAbilityDefById(param2);
         var _loc6_:BattleAbilityDef = _loc5_.getAbilityDefForLevel(param3 + 1) as BattleAbilityDef;
         var _loc7_:StatChangeData = new StatChangeData();
         if(_loc6_.tag == BattleAbilityTag.ATTACK_ARM)
         {
            if(!BattleAbility.getStatChange(_loc6_,param1.entity,StatType.ARMOR,_loc7_,param1.turnInteract,null))
            {
               return false;
            }
            _loc8_ = BattleHudDamageHelper.armorNormalDamage(param1.entity,param1.turnInteract,param3);
            this.popupEnemy.setArmorDamageText(_loc8_,_loc7_.amount);
            this.popupEnemy.setStrengthDamageText(this.strSetup[1],this.strSetup[2],0);
            return true;
         }
         if(_loc6_.tag == BattleAbilityTag.ATTACK_STR)
         {
            if(!BattleAbility.getStatChange(_loc6_,param1.entity,StatType.STRENGTH,_loc7_,param1.turnInteract,null))
            {
               return false;
            }
            _loc9_ = BattleHudDamageHelper.strengthNormalDamage(param1.entity,param1.turnInteract,param3);
            this.popupEnemy.setStrengthDamageText(_loc9_,_loc7_.amount,_loc7_.missChance);
            this.popupEnemy.setArmorDamageText(this.armSetup[1],this.armSetup[2]);
            return true;
         }
         return false;
      }
      
      private function turnAbilityHandler(param1:BattleFsmEvent) : void
      {
         this.setupPopup(this.fsm.turn as BattleTurn);
      }
      
      override protected function handleEnabled() : void
      {
         this.setupPopup(null);
      }
      
      public function update(param1:int) : void
      {
         if(popup)
         {
            popup.updatePopup(param1);
         }
      }
      
      public function handleGpButton(param1:GpControlButton) : Boolean
      {
         return Boolean(popup) && popup.handleGpButton(param1);
      }
   }
}

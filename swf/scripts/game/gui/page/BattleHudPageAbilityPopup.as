package game.gui.page
{
   import com.stoicstudio.platform.Platform;
   import com.stoicstudio.platform.PlatformInput;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityTag;
   import engine.battle.ability.def.BattleAbilityTargetRule;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.StatChangeData;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.view.BattleBoardView;
   import engine.battle.fsm.BattleTurn;
   import engine.core.gp.GpControlButton;
   import engine.stat.def.StatType;
   import engine.tile.Tile;
   import flash.geom.Point;
   import game.cfg.GameConfig;
   import game.gui.battle.IGuiAbilityPopup;
   
   public class BattleHudPageAbilityPopup
   {
      
      public static var mcClazzAbilityPopup:Class;
       
      
      private var bhp:BattleHudPage;
      
      private var config:GameConfig;
      
      private var gui:IGuiAbilityPopup;
      
      public var hud_scale:Number = 1;
      
      public function BattleHudPageAbilityPopup(param1:BattleHudPage, param2:GameConfig)
      {
         super();
         this.bhp = param1;
         this.config = param2;
         this.abilityPopupCreate();
      }
      
      public function cleanup() : void
      {
         if(this.gui)
         {
            this.gui.cleanup();
            this.gui = null;
         }
      }
      
      private function abilityPopupCreate() : void
      {
         if(Boolean(mcClazzAbilityPopup) && !this.gui)
         {
            this.gui = new mcClazzAbilityPopup() as IGuiAbilityPopup;
            this.gui.init(this.config.gameGuiContext,this.bhp);
            this.bhp.addChild(this.gui.movieClip);
            this.bhp.checkPopupHelper();
         }
      }
      
      public function resizeHandler(param1:Number, param2:Number) : void
      {
         this.hud_scale = Platform.textScale;
         this.hud_scale = Math.min(2,this.hud_scale);
         if(this.gui)
         {
            this.gui.movieClip.scaleX = this.gui.movieClip.scaleY = this.hud_scale;
         }
      }
      
      public function doConfirmClick() : void
      {
         if(this.gui)
         {
            this.gui.doConfirmClick();
         }
      }
      
      public function hide() : void
      {
         if(this.gui)
         {
            this.gui.hide();
         }
      }
      
      public function updatePopup(param1:int) : void
      {
         if(this.gui)
         {
            this.gui.updatePopup(param1);
         }
      }
      
      public function handleGpButton(param1:GpControlButton) : Boolean
      {
         return Boolean(this.gui) && this.gui.handleGpButton(param1);
      }
      
      public function handleConfirm() : Boolean
      {
         return Boolean(this.gui) && this.gui.handleConfirm();
      }
      
      public function handleTurnCommitted() : void
      {
         this.gui.hide();
      }
      
      public function handleHoverTile() : void
      {
         var _loc3_:BattleAbility = null;
         var _loc4_:* = false;
         var _loc1_:BattleTurn = this.bhp._turn;
         var _loc2_:BattleBoard = this.bhp._board;
         if(PlatformInput.lastInputGp)
         {
            if(Boolean(this.gui) && this.gui.movieClip.visible)
            {
               _loc3_ = !!_loc1_ ? _loc1_._ability : null;
               if(Boolean(_loc3_) && _loc3_.def.targetRule.isTile)
               {
                  _loc4_ = _loc2_._hoverTile == _loc3_._targetSet.lastTile;
                  this.gui.doHighlight(_loc4_);
               }
            }
         }
      }
      
      public function positionAbilityPopup() : void
      {
         var _loc4_:IBattleEntity = null;
         var _loc5_:Tile = null;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Point = null;
         var _loc11_:Point = null;
         var _loc12_:int = 0;
         var _loc13_:BattleAbilityDef = null;
         var _loc14_:int = 0;
         var _loc15_:* = null;
         var _loc16_:int = 0;
         var _loc17_:StatChangeData = null;
         if(!this.gui)
         {
            return;
         }
         var _loc1_:BattleBoardView = this.bhp.view;
         var _loc2_:BattleTurn = this.bhp.turn;
         if(!_loc2_ || !_loc2_._ability || _loc2_._ability.executed || !_loc2_.entity)
         {
            this.gui.hide();
            return;
         }
         if(!_loc2_.entity.playerControlled)
         {
            this.gui.hide();
            return;
         }
         var _loc3_:BattleAbility = _loc2_._ability;
         if(_loc3_.def.tag == BattleAbilityTag.SPECIAL)
         {
            _loc4_ = null;
            _loc5_ = null;
            if(_loc3_.targetSet.targets.length > 0)
            {
               if(_loc2_.ability.def.targetRule == BattleAbilityTargetRule.ADJACENT_BATTLEENTITY)
               {
                  _loc4_ = _loc3_.targetSet.targets[0];
               }
               else
               {
                  _loc4_ = _loc3_.targetSet.targets[_loc3_.targetSet.targets.length - 1];
               }
            }
            else if(_loc3_.targetSet.tiles.length > 0)
            {
               _loc5_ = _loc3_.targetSet.tiles[_loc3_.targetSet.tiles.length - 1];
            }
            if(Boolean(_loc4_) || Boolean(_loc5_))
            {
               if(_loc4_)
               {
                  _loc6_ = _loc4_.x + Number(_loc4_.diameter) / 2;
                  _loc7_ = _loc4_.y + Number(_loc4_.diameter) / 2;
               }
               else
               {
                  _loc6_ = _loc5_.x + _loc5_.rect.width / 2;
                  _loc7_ = _loc5_.y + _loc5_.rect.length / 2;
               }
               _loc8_ = _loc6_ * _loc1_.units;
               _loc9_ = _loc7_ * _loc1_.units;
               _loc10_ = _loc1_.getScreenPointGlobal(_loc8_,_loc9_);
               _loc11_ = this.gui.movieClip.parent.globalToLocal(_loc10_);
               this.gui.moveTo(_loc11_.x,_loc11_.y);
               _loc12_ = 0;
               if(_loc2_.ability.def.displayDamageUI)
               {
                  _loc17_ = new StatChangeData();
                  BattleAbility.getStatChange(_loc2_.ability.def,_loc2_.entity,StatType.STRENGTH,_loc17_,_loc4_,_loc2_.move);
                  _loc12_ = _loc17_.amount;
               }
               _loc13_ = _loc2_.ability.def;
               if(!_loc2_.ability.def.suppressOptionalStars)
               {
                  _loc13_ = _loc2_.entity.highestAvailableAbilityDef(_loc2_.ability.def.id) as BattleAbilityDef;
               }
               _loc14_ = 0;
               for(_loc15_ in _loc2_._inRange)
               {
                  _loc14_++;
               }
               _loc16_ = _loc2_.ability.lowestLevelAllowed;
               this.gui.show(_loc13_,_loc12_,_loc14_,_loc16_);
            }
            else
            {
               this.gui.hide();
            }
         }
      }
      
      public function starsMod(param1:int) : void
      {
         if(!this.gui)
         {
            return;
         }
         this.gui.starsMod(param1);
      }
   }
}

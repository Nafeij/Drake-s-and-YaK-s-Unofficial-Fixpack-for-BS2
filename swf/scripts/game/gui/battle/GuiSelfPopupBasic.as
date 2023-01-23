package game.gui.battle
{
   import engine.ability.def.AbilityDef;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.util.MovieClipUtil;
   import engine.gui.StickWangler;
   import engine.stat.def.StatType;
   import flash.display.MovieClip;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   
   public class GuiSelfPopupBasic extends GuiBase
   {
       
      
      private var listener:IGuiPopupListener;
      
      private var abilityDefs:Vector.<AbilityDef>;
      
      private var _entity:IBattleEntity;
      
      public var _button$move:ButtonWithIndex;
      
      public var _button$attack:ButtonWithIndex;
      
      public var _ability_button:GuiPopupAbilityButton;
      
      public var _end_turn_button:ButtonWithIndex;
      
      public var _rest_button:ButtonWithIndex;
      
      public var _crescent_in:MovieClip;
      
      private var moveExecuted:Boolean = false;
      
      private var endTurnHotkey:Boolean = false;
      
      public var crescent_in_mcu:MovieClipUtil;
      
      private var popup:GuiSelfPopup;
      
      private var wangler:StickWangler;
      
      private var _maxStars:int;
      
      private var tweener_mov:GuiSelfPopupBasic_Tweener;
      
      private var tweener_att:GuiSelfPopupBasic_Tweener;
      
      private var tweener_abl:GuiSelfPopupBasic_Tweener;
      
      private var tweener_end:GuiSelfPopupBasic_Tweener;
      
      private var tweener_res:GuiSelfPopupBasic_Tweener;
      
      private var tweening:Boolean;
      
      public function GuiSelfPopupBasic()
      {
         super();
         this.wangler = new StickWangler(this);
      }
      
      public function init(param1:IGuiContext, param2:GuiSelfPopup) : void
      {
         stop();
         this._button$move = getChildByName("button$move") as ButtonWithIndex;
         this._button$attack = getChildByName("button$attack") as ButtonWithIndex;
         this._ability_button = getChildByName("ability_button") as GuiPopupAbilityButton;
         this._end_turn_button = getChildByName("button$end_turn") as ButtonWithIndex;
         this._rest_button = getChildByName("button$rest") as ButtonWithIndex;
         this._crescent_in = getChildByName("crescent_in") as MovieClip;
         initGuiBase(param1);
         this.popup = param2;
         this.listener = param2.listener;
         this._button$move.setDownFunction(this.moveDownHandler);
         this._button$move.ttAlign = "right";
         this._button$attack.setDownFunction(this.attackDownHandler);
         this._button$attack.ttAlign = "center";
         this._ability_button.init(param1,param2);
         this._ability_button.setDownFunction(this.abilityDownHandler);
         this._ability_button.ttAlign = "right";
         this.crescent_in_mcu = new MovieClipUtil(this._crescent_in,param1.logger);
         this._rest_button.setDownFunction(this.endTurnDownHandler);
         this._end_turn_button.setDownFunction(this.endTurnDownHandler);
         this._rest_button.isToggle = true;
         this._end_turn_button.isToggle = true;
         this._button$move.guiButtonContext = param1;
         this._button$attack.guiButtonContext = param1;
         this._ability_button.guiButtonContext = param1;
         this._rest_button.guiButtonContext = param1;
         this._end_turn_button.guiButtonContext = param1;
         this.wangler.addButton(this._rest_button);
         this.wangler.addButton(this._end_turn_button);
         this.wangler.addButton(this._ability_button);
         this.wangler.addButton(this._button$attack);
         this.wangler.addButton(this._button$move);
         this.tweener_mov = new GuiSelfPopupBasic_Tweener(this._button$move);
         this.tweener_att = new GuiSelfPopupBasic_Tweener(this._button$attack);
         this.tweener_abl = new GuiSelfPopupBasic_Tweener(this._ability_button);
         this.tweener_end = new GuiSelfPopupBasic_Tweener(this._end_turn_button);
         this.tweener_res = new GuiSelfPopupBasic_Tweener(this._rest_button);
         this.stop();
      }
      
      public function cleanup() : void
      {
         this.tweener_mov.cleanup();
         this.tweener_att.cleanup();
         this.tweener_abl.cleanup();
         this.tweener_end.cleanup();
         this.tweener_res.cleanup();
         this.tweener_mov = null;
         this.tweener_att = null;
         this.tweener_abl = null;
         this.tweener_end = null;
         this.tweener_res = null;
         this.hideSelfPopupBasic();
         this.wangler.cleanup();
         this._button$move.cleanup();
         this._button$attack.cleanup();
         this._ability_button.cleanup();
         this.crescent_in_mcu.cleanup();
         this.crescent_in_mcu = null;
         this._rest_button.cleanup();
         this._end_turn_button.cleanup();
         super.cleanupGuiBase();
      }
      
      private function abilityDownHandler(param1:GuiPopupAbilityButton) : void
      {
         if(param1.blockedReason)
         {
            return;
         }
         if(!context.battleHudConfig.selfPopupSpecial)
         {
            return;
         }
         if(!this.abilityDefs || this.abilityDefs.length == 0)
         {
            return;
         }
         if(this.abilityDefs.length > 1)
         {
            this.popup.handleBasicAbilityClick();
            return;
         }
         var _loc2_:String = this.abilityDefs[0].id;
         this.listener.selfAbilitySelect(_loc2_);
         this.entity = null;
      }
      
      private function attackDownHandler(param1:ButtonWithIndex) : void
      {
         if(!context.battleHudConfig.selfPopupAttack)
         {
            return;
         }
         this.listener.selfAttackSelect();
         this.entity = null;
      }
      
      private function moveDownHandler(param1:ButtonWithIndex) : void
      {
         if(!context.battleHudConfig.selfPopupMove)
         {
            return;
         }
         this.listener.selfMoveSelect();
      }
      
      private function endTurnDownHandler(param1:ButtonWithIndex) : void
      {
         if(!context.battleHudConfig.selfPopupEnd)
         {
            if(param1)
            {
               param1.toggled = false;
            }
            return;
         }
         context.playSound("ui_generic");
         if(!param1 || !param1.toggled)
         {
            this.listener.selfEndTurnSelect();
         }
         else if(this.wangler.gpButtonPressed)
         {
            this.listener.selfEndTurnSelect();
         }
      }
      
      public function hotEndTurn(param1:IBattleEntity) : void
      {
         if(!context.battleHudConfig.selfPopupEnd)
         {
            return;
         }
         if(this.endTurnHotkey)
         {
            this.endTurnDownHandler(null);
         }
         else
         {
            this.resetSelfPopup();
            this.endTurnHotkey = true;
            this._entity = param1;
            this.visible = true;
            this.crescent_in_mcu.playOnce(null);
            if(this._rest_button.visible)
            {
               this._rest_button.toggled = true;
            }
            else
            {
               this._end_turn_button.toggled = true;
            }
         }
      }
      
      public function hideSelfPopupBasic() : void
      {
         this.endTurnHotkey = false;
         this.visible = false;
      }
      
      public function showSelfPopupBasic() : void
      {
         this.visible = true;
         this.mouseEnabled = false;
         this.mouseChildren = true;
      }
      
      public function updateWillpower(param1:int) : void
      {
         this._maxStars = param1;
         if(this._ability_button)
         {
            this._ability_button.updateWillpower(param1);
         }
      }
      
      private function resetSelfPopup(param1:ButtonWithIndex = null) : void
      {
         this.visible = true;
         this.crescent_in_mcu.playOnce(null);
         this.scaleX = this.scaleY = 1;
         this.mouseChildren = false;
         this.endTurnHotkey = false;
         this._rest_button.toggled = false;
         this._button$move.scaleX = this._button$move.scaleY = 0;
         this._button$attack.scaleX = this._button$attack.scaleY = 0;
         this._ability_button.scaleX = this._ability_button.scaleY = 0;
         this.tweening = true;
         this.tweener_res.startTween(0,100);
         this.tweener_end.startTween(0,100);
         this.tweener_att.startTween(25,100);
         this.tweener_abl.startTween(50,100);
         this.tweener_mov.startTween(75,100);
         this.updateWillpower(this._maxStars);
      }
      
      private function tweenInComplete() : void
      {
         var _loc1_:int = 0;
         var _loc2_:AbilityDef = null;
         var _loc3_:int = 0;
         this.tweening = false;
         if(!visible)
         {
            return;
         }
         this.mouseChildren = true;
         if(this.entity && this.entity.stats && this.abilityDefs && this.abilityDefs.length == 1)
         {
            _loc1_ = int(this.entity.stats.getValue(StatType.WILLPOWER));
            _loc2_ = this.abilityDefs[0];
            _loc3_ = !!_loc2_ ? _loc2_.getCost(StatType.WILLPOWER) : 0;
         }
      }
      
      public function setValues(param1:Vector.<AbilityDef>, param2:Boolean, param3:Boolean, param4:Boolean) : void
      {
         var _loc5_:AbilityDef = Boolean(param1) && param1.length == 1 ? param1[0] : null;
         this._ability_button.abilityCount = !!param1 ? param1.length : 0;
         this._ability_button.abilityDef = _loc5_;
         this.abilityDefs = param1;
         this.moveExecuted = param2;
         this._button$move.visible = !param2;
         this._button$move.mouseEnabled = this._button$move.mouseChildren = !param2;
         this._end_turn_button.visible = param2 || !param4;
         this._end_turn_button.mouseEnabled = this._rest_button.mouseChildren = param2 || !param4;
         this._end_turn_button.toggled = false;
         this._rest_button.visible = !this._end_turn_button.visible;
         this._rest_button.mouseEnabled = this._rest_button.mouseChildren = !param2;
         this._rest_button.toggled = false;
         var _loc6_:Boolean = this._entity.incorporeal;
         this._ability_button.mouseEnabled = this._ability_button.mouseChildren = !_loc6_;
         this._ability_button.visible = param4 && !_loc6_;
         this._button$attack.mouseEnabled = !_loc6_;
         this._button$attack.visible = param4 && !_loc6_;
         if(param3)
         {
            this.resetSelfPopup();
         }
      }
      
      public function getDebugString() : String
      {
         var _loc1_:String = "";
         _loc1_ += "BASIC visible=" + visible + "\n";
         _loc1_ += "BASIC abilityDefs=" + (!!this.abilityDefs ? this.abilityDefs.join(",") : "NONE") + "\n";
         _loc1_ += "BASIC moveExecuted=" + this.moveExecuted + "\n";
         return _loc1_ + this._ability_button.getDebugString();
      }
      
      public function set entity(param1:IBattleEntity) : void
      {
         if(this._entity == param1)
         {
            return;
         }
         this._entity = param1;
         if(this._entity == null)
         {
            this.hideSelfPopupBasic();
         }
         else
         {
            this.showSelfPopupBasic();
            this.resetSelfPopup();
         }
         this.abilityDefs = null;
      }
      
      public function get entity() : IBattleEntity
      {
         return this._entity;
      }
      
      public function handleConfirm() : Boolean
      {
         if(!visible)
         {
            return false;
         }
         if(this._end_turn_button.toggled)
         {
            this.listener.selfEndTurnSelect();
            return true;
         }
         return false;
      }
      
      private function checkHoverStateButton(param1:ButtonWithIndex, param2:ButtonWithIndex) : void
      {
         param2.setHovering(param2 == param1);
      }
      
      public function handleGpButton() : Boolean
      {
         if(this.wangler.visible)
         {
            return this.wangler.handleGpButton();
         }
         return false;
      }
      
      public function updatePopup(param1:int) : void
      {
         if(!visible || context.isShowingOptions)
         {
            return;
         }
         this.wangler.update(param1);
      }
      
      override public function set visible(param1:Boolean) : void
      {
         super.visible = param1;
         this.checkConfig();
      }
      
      public function checkConfig() : void
      {
         var _loc1_:Boolean = false;
         if(this.wangler)
         {
            _loc1_ = Boolean(context) && Boolean(context.battleHudConfig) && context.battleHudConfig.selfPopupWangler;
            this.wangler.visible = this.visible && _loc1_;
         }
      }
      
      public function update(param1:int) : void
      {
         var _loc2_:Boolean = false;
         if(this.tweening)
         {
            _loc2_ = this.tweener_res.updateTween(param1) || _loc2_;
            _loc2_ = this.tweener_end.updateTween(param1) || _loc2_;
            _loc2_ = this.tweener_att.updateTween(param1) || _loc2_;
            _loc2_ = this.tweener_abl.updateTween(param1) || _loc2_;
            _loc2_ = this.tweener_mov.updateTween(param1) || _loc2_;
            if(!_loc2_)
            {
               this.tweenInComplete();
            }
         }
      }
   }
}

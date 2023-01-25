package game.gui.battle
{
   import engine.battle.board.model.IBattleEntity;
   import engine.core.TutorialTooltipAlign;
   import engine.core.TutorialTooltipAnchor;
   import engine.core.gp.GpControlButton;
   import engine.core.gp.GpDevice;
   import engine.core.gp.GpSource;
   import engine.core.locale.LocaleCategory;
   import engine.core.util.MovieClipAdapter;
   import engine.gui.BattleHudConfig;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpAlignH;
   import engine.gui.GuiGpAlignV;
   import engine.gui.GuiGpBitmap;
   import engine.gui.GuiUtil;
   import engine.gui.StickWangler;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   
   public class GuiEnemyPopup extends GuiBase implements IGuiEnemyPopup
   {
      
      public static var MC_FPS:int = 48;
       
      
      private const loadButtonEndFrame:int = 8;
      
      private const textEndFrame:int = 13;
      
      private const checkmarkStartFrame:int = 14;
      
      private const checkmarkEndFrame:int = 19;
      
      private const glowFireEndFrame:int = 24;
      
      private var _entity:IBattleEntity;
      
      private var _buttonStr:GuiEnemyPopupButton;
      
      private var _buttonArm:GuiEnemyPopupButton;
      
      private var armAbilityId:String;
      
      private var strAbilityId:String;
      
      private var currentAbilityId:String;
      
      private var starsAvailable:int;
      
      private var listener:IGuiPopupListener;
      
      private var atkStrChanceToMiss:MovieClip;
      
      private var starManager:GuiPopupStarsManager;
      
      private var strNormalDamage:int = 0;
      
      private var strFinalDamage:int = 0;
      
      private var armNormalDamage:int = 0;
      
      private var armFinalDamage:int = 0;
      
      private var miss:int = 0;
      
      private var glowFire:MovieClip;
      
      private var buttonStars:Vector.<MovieClip>;
      
      private var _stars:MovieClip;
      
      private var startingParent:Sprite;
      
      private var wangler:StickWangler;
      
      private var bmp_dpad:GuiGpBitmap;
      
      private var bmp_a:GuiGpBitmap;
      
      private var bmp_b:GuiGpBitmap;
      
      private var _intro:MovieClip;
      
      private var _introMca:MovieClipAdapter;
      
      private var _crescent:MovieClip;
      
      private var _introComplete:Boolean;
      
      private var _displayDirty:Boolean = true;
      
      private var normalArmorDamage:int = 0;
      
      private var finalArmorDamage:int = 0;
      
      private var _tooltip_miss:int;
      
      private var _tooltip_miss_ok:Boolean;
      
      private var _tooltip_miss_shown_this_battle:Boolean;
      
      private var availableTargetCount:int = 0;
      
      private var starPositionsX:Array;
      
      public function GuiEnemyPopup()
      {
         this.bmp_dpad = GuiGp.ctorPrimaryBitmap(GpControlButton.D_LR);
         this.bmp_a = GuiGp.ctorPrimaryBitmap(GpControlButton.A);
         this.bmp_b = GuiGp.ctorPrimaryBitmap(GpControlButton.B);
         this.starPositionsX = [0,-25,-50];
         super();
         addChild(this.bmp_dpad);
         addChild(this.bmp_a);
         addChild(this.bmp_b);
         GpSource.dispatcher.addEventListener(GpSource.EVENT_PRIMARY_DEVICE,this.primaryDeviceHandler);
         this.wangler = new StickWangler(this);
         this.mouseEnabled = false;
         this.mouseChildren = true;
      }
      
      public function init(param1:IGuiContext, param2:IGuiPopupListener) : void
      {
         super.initGuiBase(param1);
         stop();
         this._intro = requireGuiChild("intro") as MovieClip;
         this._intro.stop();
         this._introMca = new MovieClipAdapter(this._intro,GuiEnemyPopup.MC_FPS,0,false,_context.logger,null,this.introCompleteHandler);
         this._crescent = requireGuiChild("crescent") as MovieClip;
         this._crescent.visible = true;
         this.startingParent = this.parent as Sprite;
         this.listener = param2;
         this.visible = false;
         GuiUtil.updateDisplayList(this,this.startingParent);
         this._initButtons();
         this._initStars();
         param1.battleHudConfig.addEventListener(BattleHudConfig.EVENT_CHANGED,this.configHandler);
         this.configHandler(null);
      }
      
      private function introCompleteHandler(param1:MovieClipAdapter) : void
      {
         this._introComplete = true;
         this._intro.visible = false;
         this._crescent.visible = true;
         if(!this._entity)
         {
            return;
         }
         this._buttonStr.visible = true;
         if(this._entity.stats.getStat(StatType.ARMOR,false))
         {
            this._buttonArm.visible = true;
         }
         this.configHandler(null);
         this.wangler.setStickAngle(true,0);
      }
      
      private function _initButtons() : void
      {
         this._buttonStr = requireGuiChild("button_str") as GuiEnemyPopupButton;
         this._buttonArm = requireGuiChild("button_arm") as GuiEnemyPopupButton;
         this._buttonStr.init(_context,this);
         this._buttonArm.init(_context,this);
         this.wangler.clear();
         this.wangler.addButton(this._buttonStr);
         this.wangler.addButton(this._buttonArm);
      }
      
      private function _initStars() : void
      {
         var _loc2_:MovieClip = null;
         this._stars = getChildByName("stars") as MovieClip;
         this.starManager = new GuiPopupStarsManager(this._stars,context);
         this.buttonStars = new Vector.<MovieClip>();
         var _loc1_:int = 1;
         while(_loc1_ < 4)
         {
            _loc2_ = this._stars.getChildByName("star" + _loc1_) as MovieClip;
            _loc2_.index = _loc1_;
            this.buttonStars.push(_loc2_);
            _loc1_++;
         }
         this.starManager.starsEnabled = context.battleHudConfig.enemyPopupStars;
         this.starManager.init(this.starSelected,this.starsAvailable,this.buttonStars,this.starPositionsX);
         stop();
         this._stars.visible = false;
      }
      
      override public function set visible(param1:Boolean) : void
      {
         if(super.visible != param1)
         {
            this.hideTooltip_miss();
            this._tooltip_miss_ok = false;
         }
         super.visible = param1;
         if(this.wangler)
         {
            this.configHandler(null);
         }
      }
      
      public function cleanup() : void
      {
         this.visible = false;
         this.starManager.cleanup();
         GpSource.dispatcher.removeEventListener(GpSource.EVENT_PRIMARY_DEVICE,this.primaryDeviceHandler);
         GuiGp.releasePrimaryBitmap(this.bmp_dpad);
         GuiGp.releasePrimaryBitmap(this.bmp_a);
         GuiGp.releasePrimaryBitmap(this.bmp_b);
         this.wangler.cleanup();
         this.starManager = null;
         context.battleHudConfig.removeEventListener(BattleHudConfig.EVENT_CHANGED,this.configHandler);
         this._buttonArm.cleanup();
         this._buttonStr.cleanup();
         super.cleanupGuiBase();
      }
      
      private function primaryDeviceHandler(param1:Event) : void
      {
         this._displayDirty = true;
      }
      
      private function configHandler(param1:Event) : void
      {
         if(this.starManager)
         {
            this.starManager.starsEnabled = _context.battleHudConfig.enemyPopupStars && this._introComplete;
         }
         if(this.wangler)
         {
            this.wangler.visible = context.battleHudConfig.enemyPopupWangler && this.visible && this._introComplete;
         }
      }
      
      private function setMissChance(param1:int) : void
      {
         this._buttonStr.setMissChance(param1);
      }
      
      public function setArmorDamageText(param1:int, param2:int, param3:Boolean = false) : void
      {
         var _loc5_:Stat = null;
         this.normalArmorDamage = param1;
         this.finalArmorDamage = param2;
         var _loc4_:int = 0;
         if(this.entity)
         {
            _loc5_ = this.entity.stats.getStat(StatType.ARMOR,false);
            if(_loc5_)
            {
               _loc4_ = _loc5_.modDelta;
            }
         }
         this._buttonArm.setDamageText(param1,param2,_loc4_);
      }
      
      public function setStrengthDamageText(param1:int, param2:int, param3:int) : void
      {
         this.setMissChance(param3);
         this._buttonStr.setDamageText(param1,param2,0,this.miss);
      }
      
      public function handleButtonSelected(param1:GuiEnemyPopupButton) : Boolean
      {
         this._displayDirty = true;
         if(param1 == this._buttonArm)
         {
            if(!context.battleHudConfig.enemyPopup || !context.battleHudConfig.enemyPopupArmor)
            {
               return false;
            }
            this._buttonStr.reset();
            this.currentAbilityId = this.armAbilityId;
         }
         else if(param1 == this._buttonStr)
         {
            if(!context.battleHudConfig.enemyPopup || !context.battleHudConfig.enemyPopupStrength)
            {
               return false;
            }
            this._buttonArm.reset();
            this.currentAbilityId = this.strAbilityId;
         }
         if(!this.currentAbilityId)
         {
            this._stars.visible = false;
            this.starManager.starsEnabled = false;
            return false;
         }
         this.starManager.starsEnabled = context.battleHudConfig.enemyPopupStars;
         this.starManager.resetAllStars();
         this.starManager.showStars(this.starsAvailable);
         this._stars.visible = true;
         this.listener.guiEnemyPopupSelect(this.currentAbilityId,this.starManager.starsClicked);
         this.hideTooltip_miss();
         if(param1 == this._buttonStr)
         {
            this.checkTutorialTooltipMiss();
         }
         return true;
      }
      
      public function handleButtonConfirmed(param1:GuiEnemyPopupButton) : void
      {
         this._displayDirty = true;
         if(param1 == this._buttonArm)
         {
            if(!this.armAbilityId)
            {
               return;
            }
            if(!context.battleHudConfig.enemyPopup || !context.battleHudConfig.enemyPopupArmor)
            {
               return;
            }
            if(context.battleHudConfig.enemyPopupMinStars <= this.starManager.starsClicked)
            {
               this.currentAbilityId = this.armAbilityId;
               this.listener.guiEnemyPopupExecute(this.currentAbilityId,this.starManager.starsClicked);
            }
         }
         else if(param1 == this._buttonStr)
         {
            if(context.battleHudConfig.enemyPopupMinStars <= this.starManager.starsClicked)
            {
               this.currentAbilityId = this.strAbilityId;
               this.listener.guiEnemyPopupExecute(this.currentAbilityId,this.starManager.starsClicked);
            }
         }
      }
      
      private function hideTooltip_miss() : void
      {
         if(this._tooltip_miss)
         {
            _context.removeTutorialTooltip(this._tooltip_miss);
            this._tooltip_miss = 0;
         }
      }
      
      private function checkTutorialTooltipMiss() : void
      {
         var _loc3_:String = null;
         if(this.miss <= 0)
         {
            return;
         }
         if(this._tooltip_miss_shown_this_battle && !this._tooltip_miss_ok)
         {
            return;
         }
         if(_context.saga.getVarBool("battle_hud_tips_disabled"))
         {
            return;
         }
         var _loc1_:String = "tutorial_tip_miss_remaining";
         var _loc2_:int = _context.saga.getVarInt(_loc1_);
         if(this._tooltip_miss_ok || _loc2_ > 0)
         {
            if(!this._tooltip_miss_ok)
            {
               _context.saga.setVar(_loc1_,_loc2_ - 1);
            }
            this._tooltip_miss_shown_this_battle = true;
            this._tooltip_miss_ok = true;
            _loc3_ = String(_context.translateCategory("tut_tip_miss",LocaleCategory.TUTORIAL));
            this._tooltip_miss = _context.createTutorialPopup(this._buttonStr._missText,_loc3_,TutorialTooltipAlign.RIGHT,TutorialTooltipAnchor.RIGHT,true,false,null);
            _context.setTutorialTooltipNeverClamp(this._tooltip_miss,true);
         }
      }
      
      public function set entity(param1:IBattleEntity) : void
      {
         if(param1 == this.entity)
         {
            return;
         }
         this._buttonStr.reset();
         this._buttonArm.reset();
         this._entity = param1;
         this.visible = this._entity != null;
         this._displayDirty = true;
         this.currentAbilityId = null;
         GuiUtil.updateDisplayList(this,this.startingParent);
         this._softCleanup();
         this._crescent.visible = false;
         this._buttonStr.visible = false;
         this._buttonArm.visible = false;
         this._intro.visible = visible;
         this._stars.visible = false;
         if(visible)
         {
            this._introComplete = false;
            this._introMca.playOnce();
         }
      }
      
      private function _softCleanup() : void
      {
         if(this.glowFire)
         {
            this.glowFire.stop();
            this.glowFire = null;
         }
         this.starManager.resetAllStars();
      }
      
      public function get entity() : IBattleEntity
      {
         return this._entity;
      }
      
      public function moveTo(param1:Number, param2:Number) : void
      {
         this.x = param1;
         this.y = param2;
      }
      
      public function setupPopup(param1:Array, param2:Array, param3:int, param4:int, param5:int) : void
      {
         this.availableTargetCount = param5;
         this._displayDirty = true;
         this.armAbilityId = param1[0];
         this.armNormalDamage = param1[1];
         this.armFinalDamage = param1[2];
         this.strAbilityId = param2[0];
         this.strNormalDamage = param2[1];
         this.strFinalDamage = param2[2];
         this.starsAvailable = param4;
         this.starManager.starsAvailable = param4;
         this.miss = param3;
         this.setArmorDamageText(this.armNormalDamage,this.armFinalDamage,false);
         this.setStrengthDamageText(this.strNormalDamage,this.strFinalDamage,param3);
      }
      
      public function updateWillpower(param1:int) : void
      {
         if(this._entity)
         {
            this.starsAvailable = param1;
            this.starManager.resetAllStars();
            this.starManager.starsEnabled = context.battleHudConfig.enemyPopupStars;
            if(this.starManager.starsEnabled)
            {
               this.starManager.init(this.starSelected,this.starsAvailable,this.buttonStars,this.starPositionsX);
            }
         }
      }
      
      public function starSelected() : void
      {
         var _loc1_:MovieClip = null;
         if(!this.currentAbilityId)
         {
            return;
         }
         if(this.currentAbilityId == this.armAbilityId)
         {
            this._buttonArm.glowFireVisible = this.starManager.starsClicked > 0;
            this._buttonStr.glowFireVisible = false;
         }
         else
         {
            this._buttonStr.glowFireVisible = this.starManager.starsClicked > 0;
            this._buttonArm.glowFireVisible = false;
         }
         this.listener.guiEnemyPopupSelect(this.currentAbilityId,this.starManager.starsClicked);
      }
      
      private function buttonFrameChanged(param1:Event) : void
      {
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         if(_loc2_.currentFrame == this.textEndFrame)
         {
            _loc2_.stop();
            _loc2_.removeEventListener(Event.EXIT_FRAME,this.buttonFrameChanged);
         }
         else if(_loc2_.currentFrame == this.checkmarkEndFrame)
         {
            _loc2_.stop();
            this.glowFire = _loc2_.getChildByName("glow_fire") as MovieClip;
            _loc2_.removeEventListener(Event.EXIT_FRAME,this.buttonFrameChanged);
         }
      }
      
      public function handleConfirm() : Boolean
      {
         if(!visible)
         {
            return false;
         }
         if(this._buttonArm.attemptConfirm())
         {
            return true;
         }
         if(this._buttonStr.attemptConfirm())
         {
            return true;
         }
         return false;
      }
      
      public function updatePopup(param1:int) : void
      {
         if(!visible)
         {
            return;
         }
         var _loc2_:GpDevice = GpSource.primaryDevice;
         if(!_loc2_)
         {
            return;
         }
         if(this._displayDirty)
         {
            this.resetDisplay();
         }
         this.wangler.update(param1);
      }
      
      private function resetDisplay() : void
      {
         this._displayDirty = false;
         this.bmp_a.visible = false;
         this.bmp_b.visible = false;
         this.bmp_dpad.visible = false;
         if(!this.currentAbilityId)
         {
            if(this.availableTargetCount > 1)
            {
               this.bmp_dpad.visible = true;
               this.bmp_dpad.x = -this.bmp_dpad.width / 2;
               this.bmp_dpad.y = -40 - this.bmp_dpad.height;
            }
         }
         else
         {
            if(this.currentAbilityId == this.strAbilityId)
            {
               this.bmp_a.visible = true;
               GuiGp.placeIconRight(this._buttonStr,this.bmp_a,GuiGpAlignV.N_DOWN,GuiGpAlignH.E_RIGHT);
            }
            else if(this.currentAbilityId == this.armAbilityId)
            {
               this.bmp_a.visible = true;
               GuiGp.placeIconLeft(this._buttonArm,this.bmp_a,GuiGpAlignV.N_DOWN,GuiGpAlignH.E_RIGHT);
            }
            if(this.bmp_a.visible)
            {
               this.bmp_b.visible = true;
               this.bmp_b.x = this.bmp_a.x;
               this.bmp_b.y = this.bmp_a.y + this.bmp_a.height;
            }
         }
      }
      
      public function handleGpButton_a() : Boolean
      {
         if(this.wangler.handleGpButton())
         {
            return true;
         }
         if(this.currentAbilityId == this.strAbilityId)
         {
            if(this._buttonStr.attemptConfirm())
            {
               return true;
            }
         }
         if(this.currentAbilityId == this.armAbilityId)
         {
            if(this._buttonArm.attemptConfirm())
            {
               return true;
            }
         }
         return false;
      }
      
      public function handleGpButton_b() : Boolean
      {
         var _loc1_:IBattleEntity = null;
         if(!visible)
         {
            return false;
         }
         if(this.currentAbilityId)
         {
            _loc1_ = this._entity;
            this.entity = null;
            this.entity = _loc1_;
            return true;
         }
         return false;
      }
      
      public function handleGpButton(param1:GpControlButton) : Boolean
      {
         if(!visible || !parent)
         {
            return false;
         }
         if(param1 == GpControlButton.A)
         {
            return this.handleGpButton_a();
         }
         if(param1 == GpControlButton.B)
         {
            return this.handleGpButton_b();
         }
         return false;
      }
      
      private function stickResetWakeCallbackHandler(param1:StickWangler) : void
      {
      }
   }
}

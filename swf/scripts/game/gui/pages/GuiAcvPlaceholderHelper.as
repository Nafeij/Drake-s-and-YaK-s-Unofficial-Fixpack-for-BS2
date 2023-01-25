package game.gui.pages
{
   import engine.achievement.AchievementDef;
   import engine.achievement.AchievementListDef;
   import engine.core.util.StringUtil;
   import engine.saga.Saga;
   import engine.saga.SagaAchievements;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.filters.GlowFilter;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   import game.gui.GuiIcon;
   import game.gui.GuiIconLayoutType;
   import game.gui.IGuiContext;
   
   public class GuiAcvPlaceholderHelper extends EventDispatcher
   {
      
      public static const EVENT_TOOLTIP:String = "GuiAcvPlaceholderHelper.EVENT_TOOLTIP";
      
      private static const rLum:Number = 0.2125 / 4;
      
      private static const gLum:Number = 0.7154 / 4;
      
      private static const bLum:Number = 0.0721 / 4;
      
      private static const grayscaleColorFilterMatrix:Array = [rLum,gLum,bLum,0,0,rLum,gLum,bLum,0,0,rLum,gLum,bLum,0,0,0,0,0,1,0];
       
      
      public var acv_placeholders:Vector.<MovieClip>;
      
      public var acv_icons:Vector.<GuiIcon>;
      
      private var acv_placeholdersToIndex:Dictionary;
      
      private var acv_placeholders_rect:Rectangle;
      
      private var _acv_tooltip:MovieClip;
      
      private var cmf:ColorMatrixFilter;
      
      private var glow:GlowFilter;
      
      private var container:MovieClip;
      
      private var saga:Saga;
      
      private var _context:IGuiContext;
      
      private var _alwaysUnlocked:Boolean;
      
      private var _hoverAcvPlaceholder:DisplayObjectContainer;
      
      private var _ads:Vector.<AchievementDef>;
      
      public function GuiAcvPlaceholderHelper(param1:MovieClip, param2:IGuiContext, param3:Boolean)
      {
         this.acv_placeholders = new Vector.<MovieClip>();
         this.acv_icons = new Vector.<GuiIcon>();
         this.acv_placeholdersToIndex = new Dictionary();
         this.cmf = new ColorMatrixFilter(grayscaleColorFilterMatrix);
         this.glow = new GlowFilter(10145518,1,12,12,3,2);
         this._ads = new Vector.<AchievementDef>();
         super();
         this.container = param1;
         this._context = param2;
         this.saga = param2.saga;
         this._alwaysUnlocked = param3;
         this.setupAcvPlaceholders();
         this._acv_tooltip = param1.getChildByName("acv_tooltip") as MovieClip;
         if(this._acv_tooltip)
         {
            this._acv_tooltip.mouseEnabled = this._acv_tooltip.mouseChildren = false;
            this._acv_tooltip.visible = false;
         }
      }
      
      public function cleanup() : void
      {
         var _loc1_:MovieClip = null;
         for each(_loc1_ in this.acv_placeholders)
         {
            _loc1_.removeEventListener(MouseEvent.ROLL_OUT,this.acvRollOutHandler);
            _loc1_.removeEventListener(MouseEvent.ROLL_OVER,this.acvRollOverHandler);
         }
         this.acv_placeholders = null;
         this.acv_placeholdersToIndex = null;
         this.acv_placeholders_rect = null;
         this._acv_tooltip = null;
      }
      
      private function setupAcvPlaceholders() : void
      {
         var _loc2_:String = null;
         var _loc3_:MovieClip = null;
         var _loc4_:MovieClip = null;
         var _loc1_:int = 0;
         while(_loc1_ < 20)
         {
            _loc2_ = "acv_" + _loc1_;
            _loc3_ = this.container.getChildByName(_loc2_) as MovieClip;
            if(!_loc3_)
            {
               break;
            }
            if(!this.acv_placeholders_rect)
            {
               this.acv_placeholders_rect = new Rectangle(_loc3_.x,_loc3_.y,_loc3_.width,_loc3_.height);
            }
            else
            {
               this.acv_placeholders_rect.left = Math.min(_loc3_.x,this.acv_placeholders_rect.left);
               this.acv_placeholders_rect.top = Math.min(_loc3_.y,this.acv_placeholders_rect.top);
               this.acv_placeholders_rect.right = Math.max(_loc3_.x + _loc3_.width,this.acv_placeholders_rect.right);
               this.acv_placeholders_rect.bottom = Math.max(_loc3_.y + _loc3_.height,this.acv_placeholders_rect.bottom);
            }
            _loc4_ = _loc3_.getChildByName("bg") as MovieClip;
            _loc4_.visible = false;
            _loc3_.visible = false;
            this.acv_placeholdersToIndex[_loc3_] = this.acv_placeholders.length;
            this.acv_placeholders.push(_loc3_);
            _loc3_.addEventListener(MouseEvent.ROLL_OUT,this.acvRollOutHandler);
            _loc3_.addEventListener(MouseEvent.ROLL_OVER,this.acvRollOverHandler);
            _loc1_++;
         }
      }
      
      private function acvRollOutHandler(param1:MouseEvent) : void
      {
         this.setHoverAcvPlaceholder(param1.target as MovieClip,false);
      }
      
      private function acvRollOverHandler(param1:MouseEvent) : void
      {
         this.setHoverAcvPlaceholder(param1.target as MovieClip,true);
      }
      
      public function setHoverAcvPlaceholder(param1:DisplayObjectContainer, param2:Boolean) : void
      {
         if(!this.saga || !this.saga.def)
         {
            return;
         }
         if(this._hoverAcvPlaceholder)
         {
            if(this.isUnlockedPlaceholder(this._hoverAcvPlaceholder))
            {
               this._hoverAcvPlaceholder.filters = [];
            }
            else
            {
               this._hoverAcvPlaceholder.filters = [this.cmf];
            }
         }
         if(param2)
         {
            this._hoverAcvPlaceholder = param1;
         }
         else
         {
            this._hoverAcvPlaceholder = null;
         }
         if(this._hoverAcvPlaceholder)
         {
            if(this.isUnlockedPlaceholder(this._hoverAcvPlaceholder))
            {
               this._hoverAcvPlaceholder.filters = [this.glow];
            }
            else
            {
               this._hoverAcvPlaceholder.filters = [this.cmf,this.glow];
            }
         }
         this.renderHoverAcvTooltip();
      }
      
      private function renderHoverAcvTooltip() : void
      {
         if(!this._acv_tooltip)
         {
            return;
         }
         var _loc1_:AchievementDef = this.getAchievementDefForPlaceholder(this._hoverAcvPlaceholder);
         if(!_loc1_)
         {
            this._acv_tooltip.visible = false;
            return;
         }
         var _loc2_:TextField = this._acv_tooltip.getChildByName("text") as TextField;
         var _loc3_:String = "";
         _loc3_ += "<font color=\'#ffff00\'>" + _loc1_.name + "</font>\n";
         _loc3_ += _loc1_.description;
         _loc2_.htmlText = _loc3_;
         this._context.locale.fixTextFieldFormat(_loc2_);
         this._acv_tooltip.visible = true;
         this._acv_tooltip.y = this._hoverAcvPlaceholder.y + 140;
         this._acv_tooltip.x = this._hoverAcvPlaceholder.x + 66 - this._acv_tooltip.width / 2;
         this._acv_tooltip.x = Math.max(this.acv_placeholders_rect.left,this._acv_tooltip.x);
         this._acv_tooltip.x = Math.min(this.acv_placeholders_rect.right - this._acv_tooltip.width,this._acv_tooltip.x);
         dispatchEvent(new Event(EVENT_TOOLTIP));
      }
      
      private function isUnlockedPlaceholder(param1:DisplayObjectContainer) : Boolean
      {
         if(this._alwaysUnlocked)
         {
            return true;
         }
         var _loc2_:AchievementDef = this.getAchievementDefForPlaceholder(param1);
         return Boolean(_loc2_) && SagaAchievements.isUnlocked(_loc2_.id);
      }
      
      private function getAchievementDefForPlaceholder(param1:DisplayObjectContainer) : AchievementDef
      {
         if(!param1 || !this.saga || !this.saga.def)
         {
            return null;
         }
         var _loc2_:int = int(this.acv_placeholdersToIndex[param1]);
         if(_loc2_ < 0 || _loc2_ >= this.saga.def.achievements.defs.length)
         {
            return null;
         }
         return this._ads[_loc2_];
      }
      
      public function addAchievement(param1:String) : MovieClip
      {
         var _loc3_:AchievementDef = null;
         var _loc5_:MovieClip = null;
         var _loc2_:AchievementListDef = this.saga.def.achievements;
         if(!_loc2_)
         {
            return null;
         }
         _loc3_ = _loc2_.fetch(param1);
         if(!_loc3_)
         {
            this._context.logger.error("Bogus achievement [" + param1 + "]");
            return null;
         }
         var _loc4_:int = int(this.acv_icons.length);
         if(_loc4_ >= this.acv_placeholders.length)
         {
            this._context.logger.error("Too many achievements?");
            return null;
         }
         this._ads.push(_loc3_);
         _loc5_ = this.acv_placeholders[_loc4_];
         _loc5_.visible = true;
         var _loc6_:GuiIcon = this._context.getIcon(_loc3_.iconUrl);
         _loc6_.layout = GuiIconLayoutType.ACTUAL;
         _loc6_.x = _loc6_.y = 0;
         _loc6_.name = "acv_icon_" + StringUtil.padLeft(_loc4_.toString(),"0",2);
         _loc5_.addChild(_loc6_);
         this.acv_icons.push(_loc6_);
         if(!(this._alwaysUnlocked || SagaAchievements.isUnlocked(_loc3_.id)))
         {
            _loc5_.filters = [this.cmf];
         }
         return _loc5_;
      }
   }
}

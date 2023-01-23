package game.gui
{
   import engine.core.logging.ILogger;
   import engine.entity.def.EntityDefEvent;
   import engine.entity.def.EntityIconType;
   import engine.entity.def.IEntityDef;
   import engine.gui.GuiUtil;
   import engine.saga.Saga;
   import engine.stat.def.StatType;
   import flash.display.MovieClip;
   import flash.errors.IllegalOperationError;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   
   public class GuiCharacterIconSlot extends GuiIconSlot implements IGuiCharacterIconSlot
   {
      
      public static var mcStatTooltipClazz:Class;
       
      
      private var _character:IEntityDef;
      
      private var _type:EntityIconType;
      
      public var _item:MovieClip;
      
      public var _tooltip_injury:MovieClip;
      
      public var tooltip_injury_text:TextField;
      
      public var tooltip_injury_text_rect:Rectangle;
      
      public var _tooltip_stats:GuiStatsTooltip;
      
      public var _plus:MovieClip;
      
      public var _icon_recruitable:MovieClip;
      
      public var _icon_dead:MovieClip;
      
      private var _showStatsTooltip:Boolean = false;
      
      public function GuiCharacterIconSlot()
      {
         super();
         this._item = getChildByName("item") as MovieClip;
         this._plus = getChildByName("plus") as MovieClip;
         this._icon_recruitable = getChildByName("recruitable") as MovieClip;
         this._icon_dead = getChildByName("dead") as MovieClip;
         if(this._plus)
         {
            this._plus.visible = false;
         }
         if(this._icon_recruitable)
         {
            this._icon_recruitable.visible = false;
         }
         if(this._icon_dead)
         {
            this._icon_dead.visible = false;
         }
         stop();
      }
      
      public function set showRecruitable(param1:Boolean) : void
      {
         if(this._icon_recruitable)
         {
            this._icon_recruitable.visible = param1;
         }
      }
      
      public function set showDead(param1:Boolean) : void
      {
         if(this._icon_dead)
         {
            this._icon_dead.visible = param1;
         }
      }
      
      override public function init(param1:IGuiContext) : void
      {
         var _loc2_:String = null;
         var _loc3_:ILogger = null;
         var _loc4_:MovieClip = null;
         super.init(param1);
         if(!this._tooltip_injury)
         {
            this._tooltip_injury = getChildByName("tooltip_injury") as MovieClip;
         }
         if(this._tooltip_injury)
         {
            this.tooltip_injury_text = this._tooltip_injury.getChildByName("text") as TextField;
            this._tooltip_injury.visible = false;
            this.tooltip_injury_text_rect = this.tooltip_injury_text.getBounds(this._tooltip_injury);
            removeChild(this._tooltip_injury);
         }
         if(this._icon_dead)
         {
            _loc2_ = param1.censorId;
            _loc3_ = param1.logger;
            _loc4_ = this._icon_dead.getChildByName("censor") as MovieClip;
            GuiUtil.performCensor(_loc4_,_loc2_,_loc3_);
         }
         this._tooltip_stats = new mcStatTooltipClazz() as GuiStatsTooltip;
         if(Boolean(this._tooltip_stats) && Boolean(this.parent))
         {
            this.parent.addChild(this._tooltip_stats);
            this._tooltip_stats.x = this.x + this.iconRect.right;
            this._tooltip_stats.y = this.y;
         }
         else
         {
            this._tooltip_stats.cleanup();
            this._tooltip_stats = null;
         }
         if(Boolean(this._character) && Boolean(this._tooltip_stats))
         {
            this._tooltip_stats.setEntityValues(this._character.stats);
         }
      }
      
      override public function cleanup() : void
      {
         this.setCharacter(null,null);
         if(this._tooltip_stats)
         {
            this._tooltip_stats.cleanup();
            this._tooltip_stats = null;
         }
         super.cleanup();
      }
      
      override public function setHovering(param1:Boolean) : void
      {
         super.setHovering(param1);
         this.rolledOver = param1;
         this.handleRolledOver();
      }
      
      override protected function handleRolledOver() : void
      {
         if(this._tooltip_injury)
         {
            this._tooltip_injury.visible = rolledOver && Boolean(_injuryDays);
            if(this._tooltip_injury.visible && !this._tooltip_injury.parent)
            {
               addChild(this._tooltip_injury);
            }
            else if(!this._tooltip_injury.visible && Boolean(this._tooltip_injury.parent))
            {
               removeChild(this._tooltip_injury);
            }
         }
         if(this._tooltip_stats)
         {
            this._tooltip_stats.visible = rolledOver && Boolean(this._character) && this.showStatsTooltip;
         }
      }
      
      override public function set injuryDays(param1:int) : void
      {
         var _loc2_:String = null;
         super.injuryDays = param1;
         if(_injuryDays)
         {
            if(this.tooltip_injury_text)
            {
               _loc2_ = context.translate("injury_tooltip");
               _loc2_ = _loc2_.replace("$INJURY",(-_injuryDays).toString());
               this.tooltip_injury_text.htmlText = _loc2_;
               if(_context)
               {
                  _context.locale.fixTextFieldFormat(this.tooltip_injury_text);
               }
               GuiUtil.scaleTextToFit2d(this.tooltip_injury_text,this.tooltip_injury_text_rect.width,this.tooltip_injury_text_rect.height,true);
            }
         }
         this.handleRolledOver();
      }
      
      public function updatePowerText() : void
      {
         if(this._character)
         {
            powerText = this._character.power.toString();
         }
      }
      
      public function setCharacter(param1:IEntityDef, param2:EntityIconType) : void
      {
         if(!context)
         {
            throw new IllegalOperationError("give me an IGuiContent before fiddling with me, please...");
         }
         if(this._character)
         {
            this._character.removeEventListener(EntityDefEvent.APPEARANCE,this.unitAppearanceHandler);
            this._character.removeEventListener(EntityDefEvent.ITEM,this.unitAppearanceHandler);
         }
         this._type = param2;
         this._character = param1;
         if(this._character)
         {
            this._character.addEventListener(EntityDefEvent.APPEARANCE,this.unitAppearanceHandler);
            this._character.addEventListener(EntityDefEvent.ITEM,this.unitAppearanceHandler);
         }
         this.update();
      }
      
      private function unitAppearanceHandler(param1:EntityDefEvent) : void
      {
         this.update();
      }
      
      private function update() : void
      {
         var _loc1_:int = 0;
         if(this._item)
         {
            this._item.visible = Boolean(this._character) && Boolean(this._character.defItem);
         }
         if(this._character)
         {
            icon = context.getEntityIcon(this._character,this._type);
            nameText = this._character.name;
            rankText = this._character.stats.getValue(StatType.RANK).toString();
            powerText = this._character.power.toString();
            _loc1_ = int(this._character.stats.getValue(StatType.INJURY));
            if(Boolean(Saga.instance) && Boolean(Saga.instance.def.survival))
            {
               this.showRecruitable = !this._character.isSurvivalRecruited;
               this.showDead = _loc1_ != 0;
               this.injuryDays = 0;
            }
            else
            {
               this.injuryDays = _loc1_;
            }
            if(this._tooltip_stats)
            {
               this._tooltip_stats.setEntityValues(this._character.stats);
            }
         }
         else
         {
            this.showRecruitable = false;
            this.showDead = false;
            icon = null;
            nameText = null;
            rankText = null;
            powerText = null;
            this.injuryDays = 0;
         }
         this.updatePlus();
      }
      
      private function updatePlus() : void
      {
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:Boolean = false;
         if(!this._plus)
         {
            return;
         }
         if(!this._character)
         {
            this._plus.visible = false;
            return;
         }
         var _loc1_:Saga = Saga.instance;
         var _loc2_:int = int(this._character.stats.getValue(StatType.RANK));
         var _loc3_:int = this._character.statRanges.getStatRange(StatType.RANK).max;
         if(_loc2_ < _loc3_)
         {
            _loc8_ = int(this._character.stats.getValue(StatType.KILLS));
            _loc9_ = context.statCosts.getKillsRequiredToPromote(_loc2_);
            if(_loc8_ >= _loc9_)
            {
               _loc10_ = true;
               if(Boolean(_loc1_) && Boolean(_loc1_.def.survival))
               {
                  _loc10_ = false;
               }
               if(_loc10_)
               {
                  this._plus.visible = true;
                  return;
               }
            }
         }
         var _loc4_:int = int(this._character.stats.GetTotalUpgrades(this._character.statRanges));
         var _loc5_:int = this._character.getMaxUpgrades(context.entitiesMetadata,_context.statCosts);
         var _loc6_:int = !!this._character.talents ? this._character.talents.totalRanks : 0;
         var _loc7_:int = _loc5_ - _loc4_ - _loc6_;
         if(!this._character.isSurvivalPromotable)
         {
            _loc7_ = 0;
         }
         if(_loc7_ > 0)
         {
            this._plus.visible = true;
            return;
         }
         this._plus.visible = false;
      }
      
      public function get character() : IEntityDef
      {
         return this._character;
      }
      
      override public function handleLocaleChange() : void
      {
         super.handleLocaleChange();
         this.update();
      }
      
      override public function get showStatsTooltip() : Boolean
      {
         return this._showStatsTooltip;
      }
      
      override public function set showStatsTooltip(param1:Boolean) : void
      {
         this._showStatsTooltip = param1;
      }
   }
}

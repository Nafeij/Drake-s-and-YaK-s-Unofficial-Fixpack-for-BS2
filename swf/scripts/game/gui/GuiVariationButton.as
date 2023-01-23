package game.gui
{
   import engine.entity.def.IEntityAppearanceDef;
   import engine.entity.def.IEntityDef;
   import flash.display.MovieClip;
   import flash.text.TextField;
   import game.gui.page.GuiPromotionConfig;
   
   public class GuiVariationButton extends ButtonWithIndex
   {
       
      
      public var _renownCost:MovieClip;
      
      public var _renownCostText:TextField;
      
      public var _icon:MovieClip;
      
      public var _marketIcon:MovieClip;
      
      private var _appearance:IEntityAppearanceDef;
      
      private var entity:IEntityDef;
      
      private var guiConfig:GuiPromotionConfig;
      
      public var appearanceIndex:int;
      
      public function GuiVariationButton()
      {
         super();
         isToggle = false;
         this._renownCost = getChildByName("renownCost") as MovieClip;
         this._renownCostText = getChildByName("renownCostText") as TextField;
         this._icon = getChildByName("icon") as MovieClip;
         this._marketIcon = getChildByName("marketIcon") as MovieClip;
      }
      
      public function init(param1:IGuiContext, param2:GuiPromotionConfig) : void
      {
         super.guiButtonContext = param1;
         this.guiConfig = param2;
         this._renownCostText = this._renownCost.getChildByName("costText") as TextField;
      }
      
      public function setup(param1:IEntityAppearanceDef, param2:IEntityDef, param3:String, param4:int, param5:Function, param6:Function, param7:Function) : void
      {
         this._appearance = param1;
         this.entity = param2;
         this.index = index;
         this.appearanceIndex = param4;
         toggled = false;
         this._renownCost.visible = false;
         this._marketIcon.visible = false;
         if(!this._appearance || !param2)
         {
            return;
         }
         if(_context.hasUnlock(this._appearance.acquire_id) || param2.isAppearanceAcquired(param4))
         {
            setDownFunction(param5);
         }
         else if(_context.hasUnlock(this._appearance.unlock_id) && !_context.hasUnlock(this._appearance.acquire_id))
         {
            this._renownCost.visible = true;
            this._renownCostText.htmlText = _context.statCosts.getVariationCost().toString();
            setDownFunction(param6);
         }
         else if(!_context.hasUnlock(this._appearance.unlock_id))
         {
            this._marketIcon.visible = true;
            setDownFunction(param7);
         }
         else
         {
            _context.logger.error("invalid appearance state for: " + param3);
         }
         buttonText = param3;
         if(this._icon.numChildren > 0)
         {
            this._icon.removeChildAt(0);
         }
         this._icon.addChild(_context.getEntityAppearancePromotePortrait(this._appearance));
         if(this.guiConfig.disabled && !this.guiConfig.allowVariation && param4 != this.guiConfig.variationIndex)
         {
            setDownFunction(null);
         }
      }
   }
}

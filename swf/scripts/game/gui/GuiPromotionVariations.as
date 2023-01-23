package game.gui
{
   import engine.entity.def.IEntityAppearanceDef;
   import engine.entity.def.IEntityClassDef;
   import engine.entity.def.IEntityDef;
   import game.gui.page.GuiPromotionConfig;
   import tbs.srv.util.InAppPurchaseItemDef;
   
   public class GuiPromotionVariations extends GuiBase
   {
       
      
      private var _entity:IEntityDef;
      
      private var activeClassIndex:int;
      
      private var currentCharacterClass:IEntityClassDef;
      
      private const chitCount:int = 4;
      
      public var variationIndex:int;
      
      public var variationFromBio:Boolean = false;
      
      private var randomNameButton:ButtonWithIndex;
      
      private var guiConfig:GuiPromotionConfig;
      
      private var _cost:int;
      
      public var setupVariationConfirmCancel:Function;
      
      public var costChangedCallback:Function;
      
      private var variationButtons:Vector.<GuiVariationButton>;
      
      public function GuiPromotionVariations()
      {
         this.variationButtons = new Vector.<GuiVariationButton>();
         super();
      }
      
      public function init(param1:IGuiContext, param2:GuiPromotionConfig, param3:Function, param4:Function) : void
      {
         this.initGuiBase(param1);
         this.guiConfig = param2;
         this.setupVariationConfirmCancel = param3;
         this.costChangedCallback = param4;
      }
      
      public function cleanup() : void
      {
         var _loc1_:GuiVariationButton = null;
         this.setupVariationConfirmCancel = null;
         this.costChangedCallback = null;
         if(this.randomNameButton)
         {
            this.randomNameButton.cleanup();
            this.randomNameButton = null;
         }
         for each(_loc1_ in this.variationButtons)
         {
            _loc1_.cleanup();
         }
         this.variationButtons = null;
         this.entity = null;
         super.cleanupGuiBase();
      }
      
      public function get entity() : IEntityDef
      {
         return this._entity;
      }
      
      public function set entity(param1:IEntityDef) : void
      {
         this._entity = param1;
         if(this._entity)
         {
            this.currentCharacterClass = this._entity.entityClass;
         }
      }
      
      public function bioVariation(param1:IEntityDef) : void
      {
         this.variationFromBio = true;
         this.entity = param1;
         this.variationMode(param1.entityClass);
      }
      
      private function turnOffOtherTogggles(param1:String) : void
      {
         var _loc3_:ButtonWithIndex = null;
         var _loc2_:int = 0;
         while(_loc2_ < this.currentCharacterClass.appearanceDefs.length)
         {
            _loc3_ = getChildByName("_" + _loc2_) as ButtonWithIndex;
            if(_loc3_.name != param1)
            {
               _loc3_.isToggle = false;
               _loc3_.toggled = false;
            }
            _loc2_++;
         }
      }
      
      public function variationMode(param1:IEntityClassDef) : void
      {
         var _loc3_:GuiVariationButton = null;
         var _loc4_:String = null;
         var _loc5_:IEntityAppearanceDef = null;
         this.currentCharacterClass = param1;
         this.variationIndex = 0;
         visible = true;
         var _loc2_:int = 0;
         while(_loc2_ < this.currentCharacterClass.appearanceDefs.length)
         {
            _loc3_ = getChildByName("_" + _loc2_) as GuiVariationButton;
            this.variationButtons.push(_loc3_);
            _loc3_.init(context,this.guiConfig);
            _loc4_ = this.currentCharacterClass.getAppearanceName(_loc2_);
            _loc5_ = this.currentCharacterClass.appearanceDefs[_loc2_];
            _loc3_.setup(_loc5_,this.entity,_loc4_,_loc2_,this.onAcquiredVariationButtonClick,this.onRenownCostVariationButtonClick,this.onStoreOnlyVariationButtonClick);
            _loc2_++;
         }
      }
      
      private function onAcquiredVariationButtonClick(param1:GuiVariationButton) : void
      {
         this.turnOffOtherTogggles(param1.name);
         this.variationIndex = param1.appearanceIndex;
         this.setupVariationConfirmCancel();
         param1.isToggle = !param1.isToggle;
         param1.toggled = param1.isToggle;
         if(this.guiConfig.disabled && !this.guiConfig.allowVariation)
         {
            param1.setDownFunction(null);
         }
         this.cost = this.variationFromBio ? 0 : context.statCosts.getPromotionCost(this.entity.stats.rank);
      }
      
      private function onRenownCostVariationButtonClick(param1:GuiVariationButton) : void
      {
         this.turnOffOtherTogggles(param1.name);
         this.variationIndex = param1.appearanceIndex;
         param1.isToggle = !param1.isToggle;
         param1.toggled = param1.isToggle;
         this.cost = context.statCosts.getVariationCost();
         this.setupVariationConfirmCancel();
      }
      
      private function marketCallback() : void
      {
         if(this.entity)
         {
            this.variationMode(this.entity.entityClass);
         }
         else
         {
            this.variationMode(null);
         }
      }
      
      private function onStoreOnlyVariationButtonClick(param1:GuiVariationButton) : void
      {
         if(!context.iap)
         {
            context.logger.error("no IAP for store only variation");
            return;
         }
         this.variationIndex = param1.appearanceIndex;
         var _loc2_:IEntityAppearanceDef = this.currentCharacterClass.appearanceDefs[this.variationIndex];
         if(context.iap.itemList.findItemsByUnlock(_loc2_.unlock_id).length <= 0)
         {
            context.logger.error("unable to locate the unlock id called: " + _loc2_.unlock_id + " consult Jenkins or check character_classes.");
            return;
         }
         var _loc3_:Vector.<InAppPurchaseItemDef> = context.iap.itemList.findItemsByUnlock(_loc2_.unlock_id);
         var _loc4_:InAppPurchaseItemDef = _loc3_[0];
      }
      
      public function get cost() : int
      {
         return this._cost;
      }
      
      public function set cost(param1:int) : void
      {
         this._cost = param1;
         this.costChangedCallback();
      }
   }
}

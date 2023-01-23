package game.gui.pages
{
   import com.stoicstudio.platform.PlatformInput;
   import engine.entity.def.EntityDefEvent;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.Item;
   import engine.entity.def.ItemDef;
   import engine.stat.def.StatType;
   import flash.display.Stage;
   import flash.events.MouseEvent;
   import game.gui.ButtonWithIndex;
   import game.gui.GuiBase;
   import game.gui.GuiIconSlot;
   import game.gui.GuiIconSlotEvent;
   import game.gui.GuiItemInfo;
   import game.gui.GuiItemSlot;
   import game.gui.GuiItemSlots;
   import game.gui.IGuiContext;
   import game.gui.IGuiDialog;
   
   public class GuiPgDetailsItem extends GuiBase
   {
       
      
      public var _items:GuiItemSlots;
      
      public var _item:GuiItemSlot;
      
      public var _item_info:GuiItemInfo;
      
      public var _button_item_plus:ButtonWithIndex;
      
      public var _button_item_minus:ButtonWithIndex;
      
      private var _entity:IEntityDef;
      
      private var theStage:Stage;
      
      private var _activationCallback:Function;
      
      private var _isDialogOpen:Boolean;
      
      private var _lastOkItemDrop:GuiIconSlot;
      
      private var _draggingItem:GuiItemSlot;
      
      private var dialog:IGuiDialog;
      
      public function GuiPgDetailsItem()
      {
         super();
         this._items = getChildByName("items") as GuiItemSlots;
         this._item = getChildByName("item") as GuiItemSlot;
         this._item_info = getChildByName("item_info") as GuiItemInfo;
         this._button_item_plus = getChildByName("button_item_plus") as ButtonWithIndex;
         this._button_item_minus = getChildByName("button_item_minus") as ButtonWithIndex;
      }
      
      public function init(param1:IGuiContext, param2:Function) : void
      {
         super.initGuiBase(param1);
         this._activationCallback = param2;
         this._items.init(param1,this.itemSlotsActivationHandler,this.itemSlotsGiveHandler,this.itemSlotsRemoveHandler);
         this._item.init(param1);
         this._item.dragEnabled = false;
         this._item_info.init(param1);
         this._item.ownerEnabled = false;
         this._items.addIconEventListener(GuiIconSlotEvent.DRAG_START,this.dragStartHandler);
         this._items.addIconEventListener(GuiIconSlotEvent.DRAG_END,this.dragEndHandler);
         this._item.addEventListener(GuiIconSlotEvent.DROP,this.dropHandler);
         this._item.addEventListener(GuiIconSlotEvent.CLICKED,this.clickHandler);
         this._button_item_plus.guiButtonContext = param1;
         this._button_item_minus.guiButtonContext = param1;
         this._button_item_plus.setDownFunction(this.buttonItemPlusHandler);
         this._button_item_minus.setDownFunction(this.buttonItemMinusHandler);
         this._button_item_minus.visible = PlatformInput.hasClicker;
         this._button_item_plus.visible = PlatformInput.hasClicker;
         this.theStage = stage;
         if(this.theStage)
         {
            this.theStage.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
         }
         this.setup();
      }
      
      public function get isDialogOpen() : Boolean
      {
         return this._isDialogOpen;
      }
      
      override public function set visible(param1:Boolean) : void
      {
         super.visible = param1;
      }
      
      public function handleLocaleChanged() : void
      {
         if(this._item_info)
         {
            this._item_info.handleLocaleChange();
         }
         if(this._items)
         {
            this._items.handleLocaleChanged();
         }
      }
      
      private function clickHandler(param1:GuiIconSlotEvent) : void
      {
         if(this._item_info.visible || this._items.visible)
         {
            this._item_info.itemDef = null;
            this._items.visible = false;
         }
         else
         {
            this._item_info.itemDef = Boolean(this._entity) && Boolean(this._entity.defItem) ? this._entity.defItem.def : null;
            if(!this._item_info.itemDef)
            {
               this.buttonItemPlusHandler(null);
            }
         }
         this.updateModButtons();
      }
      
      private function dragStartHandler(param1:GuiIconSlotEvent) : void
      {
         this._draggingItem = param1.target as GuiItemSlot;
         this._lastOkItemDrop = null;
         context.playSound("ui_stats_wipes_minor");
      }
      
      private function dragEndHandler(param1:GuiIconSlotEvent) : void
      {
         this._draggingItem = null;
         var _loc2_:GuiItemSlot = param1.target as GuiItemSlot;
         if(_loc2_ != this._lastOkItemDrop)
         {
            context.playSound("ui_dismiss");
         }
      }
      
      private function dropHandler(param1:GuiIconSlotEvent) : void
      {
         if(!this.entity)
         {
            return;
         }
         var _loc2_:GuiItemSlot = GuiIconSlot.draggedSourceIconSlot as GuiItemSlot;
         if(!_loc2_)
         {
            return;
         }
         if(_loc2_.item)
         {
            this._lastOkItemDrop = _loc2_;
            this.handleGiveItem(_loc2_.item);
         }
      }
      
      private function handleGiveItem(param1:Item) : Boolean
      {
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         if(!param1)
         {
            return false;
         }
         var _loc2_:int = this._entity.stats.getValue(StatType.RANK) - 1;
         var _loc3_:int = param1.def.rank;
         if(_loc2_ < _loc3_)
         {
            this.dialog = context.createDialog();
            _loc4_ = param1.def.colorizedName;
            _loc5_ = context.translate("item_too_powerful_title");
            _loc6_ = context.translate("item_too_powerful_body");
            _loc6_ = _loc6_.replace("$NAME",this._entity.name);
            _loc6_ = _loc6_.replace("$RANK",_loc3_.toString());
            _loc6_ = _loc6_.replace("$ITEM",_loc4_);
            _loc7_ = context.translate("ok");
            this._isDialogOpen = true;
            this.dialog.openDialog(_loc5_,_loc6_,_loc7_,this.dialogClosedHandler);
            context.playSound("ui_error");
            return false;
         }
         context.legend.putItemOnEntity(this.entity,param1);
         context.playSound("ui_travel_press");
         return true;
      }
      
      private function dialogClosedHandler(param1:String) : void
      {
         this.dialog = null;
         this._isDialogOpen = false;
      }
      
      private function mouseDownHandler(param1:MouseEvent) : void
      {
         if(this.dialog)
         {
            return;
         }
         if(!hitTestPoint(param1.stageX,param1.stageY,true))
         {
            this.setup();
         }
      }
      
      public function cleanup() : void
      {
         super.cleanupGuiBase();
         this._items.removeIconEventListener(GuiIconSlotEvent.DRAG_START,this.dragStartHandler);
         this._items.removeIconEventListener(GuiIconSlotEvent.DRAG_END,this.dragEndHandler);
         this._button_item_plus.cleanup();
         this._button_item_minus.cleanup();
         if(this.theStage)
         {
            this.theStage.removeEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
         }
         if(this.dialog)
         {
            this.dialog.closeDialog(null);
         }
         this.entity = null;
         this._item_info.itemDef = null;
         this._items.cleanup();
         this._item.cleanup();
         this._items = null;
         this._item = null;
         this._activationCallback = null;
      }
      
      private function buttonItemPlusHandler(param1:ButtonWithIndex) : void
      {
         this._items.visible = true;
      }
      
      private function buttonItemMinusHandler(param1:ButtonWithIndex) : void
      {
         if(this.removeItem())
         {
            this.updateModButtons();
         }
      }
      
      private function removeItem() : Boolean
      {
         if(Boolean(this._entity) && Boolean(this._entity.defItem))
         {
            this._entity.defItem.owner = null;
            context.legend.items.addItem(this._entity.defItem);
            this._entity.defItem = null;
            this._item_info.itemDef = null;
            return true;
         }
         return false;
      }
      
      public function get entity() : IEntityDef
      {
         return this._entity;
      }
      
      public function set entity(param1:IEntityDef) : void
      {
         if(this._entity == param1)
         {
            return;
         }
         if(this._entity)
         {
            this._entity.removeEventListener(EntityDefEvent.ITEM,this.entityItemHandler);
         }
         this._entity = param1;
         if(this._entity)
         {
            this._entity.addEventListener(EntityDefEvent.ITEM,this.entityItemHandler);
         }
         this.setup();
      }
      
      private function entityItemHandler(param1:EntityDefEvent) : void
      {
         this._item.item = !!this._entity ? this._entity.defItem : null;
         this.resetList();
      }
      
      private function resetList() : void
      {
         if(!this._entity || !_context || !_context.legend)
         {
            return;
         }
         var _loc1_:Vector.<Item> = context.legend.getAllSortedItems(null);
         var _loc2_:int = this._entity.stats.getValue(StatType.RANK) - 1;
         this._items.setItems(_loc1_,_loc2_);
         if(this._items.visible)
         {
            this._item_info.itemDef = !!this._entity.defItem ? this._entity.defItem.def : null;
         }
         this.updateModButtons();
      }
      
      private function updateModButtons() : void
      {
         var _loc1_:Item = !!this._entity ? this._entity.defItem : null;
         var _loc2_:int = !!this._items.items ? this._items.items.length : int(null);
         if(_loc1_)
         {
            _loc2_--;
         }
         this._button_item_plus.visible = _loc2_ > 0 && (!_loc1_ || this._item_info.visible) && PlatformInput.hasClicker;
         this._button_item_minus.visible = this._item_info.visible && PlatformInput.hasClicker;
         this._button_item_plus.enabled = !this._items.visible;
      }
      
      private function setup() : void
      {
         this._items.visible = false;
         this._item_info.visible = false;
         this.entityItemHandler(null);
      }
      
      public function get isActivatedGp() : Boolean
      {
         return this._items.isActivatedGp;
      }
      
      private function itemSlotsActivationHandler() : void
      {
         if(!this._items.isActivatedGp)
         {
            this._items.visible = false;
            this._item_info.itemDef = null;
         }
         else
         {
            this._items.visible = true;
            this._item_info.itemDef = Boolean(this._entity) && Boolean(this._entity.defItem) ? this._entity.defItem.def : null;
         }
         if(this._activationCallback != null)
         {
            this._activationCallback();
         }
      }
      
      private function itemSlotsGiveHandler(param1:GuiItemSlot) : Boolean
      {
         if(!this._draggingItem)
         {
            this.handleGiveItem(param1.item);
         }
         return true;
      }
      
      private function itemSlotsRemoveHandler(param1:GuiItemSlot) : void
      {
         this.removeItem();
      }
      
      public function activateGp() : void
      {
         this.visible = true;
         this._items.visible = true;
         this._items.activateGp(this._entity);
      }
      
      public function deactivateGp() : void
      {
         this._items.visible = false;
         this._item_info.itemDef = null;
         this._items.deactivateGp();
      }
   }
}

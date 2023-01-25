package game.gui
{
   import engine.core.cmd.Cmd;
   import engine.core.cmd.CmdExec;
   import engine.core.gp.GpBinder;
   import engine.core.gp.GpControlButton;
   import engine.core.locale.LocaleCategory;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.Item;
   import engine.entity.def.ItemDef;
   import engine.gui.GuiGp;
   import engine.gui.GuiGpAlignH;
   import engine.gui.GuiGpAlignV;
   import engine.gui.GuiGpBitmap;
   import engine.gui.GuiGpNav;
   import flash.display.DisplayObject;
   import flash.display.Stage;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class GuiItemSlots extends GuiBase
   {
       
      
      public var iconSlots:Vector.<GuiItemSlot>;
      
      public var _button_item_left:ButtonWithIndex;
      
      public var _button_item_right:ButtonWithIndex;
      
      public var _info:GuiItemInfo;
      
      public var _$items:TextField;
      
      private var scrollIndex:int = 0;
      
      private var maxScrollIndex:int;
      
      public var items:Vector.<Item>;
      
      public var nav:GuiGpNav;
      
      private var cmd_pg_items_left:Cmd;
      
      private var cmd_pg_items_right:Cmd;
      
      private var gp_l1:GuiGpBitmap;
      
      private var gp_r1:GuiGpBitmap;
      
      private var activationCallback:Function;
      
      private var giveCallback:Function;
      
      private var removeCallback:Function;
      
      private var theStage:Stage;
      
      private var maxRank:int = 100;
      
      private var gplayer:int;
      
      private var _entity:IEntityDef;
      
      public function GuiItemSlots()
      {
         this.iconSlots = new Vector.<GuiItemSlot>();
         this.cmd_pg_items_left = new Cmd("cmd_pg_items_left",this.cmdfunc_pg_items_left);
         this.cmd_pg_items_right = new Cmd("cmd_pg_items_right",this.cmdfunc_pg_items_right);
         super();
         this._button_item_left = getChildByName("button_item_left") as ButtonWithIndex;
         this._button_item_right = getChildByName("button_item_right") as ButtonWithIndex;
         this._info = getChildByName("info") as GuiItemInfo;
         this._$items = getChildByName("$items") as TextField;
         registerScalableTextfield(this._$items);
      }
      
      public function init(param1:IGuiContext, param2:Function, param3:Function, param4:Function) : void
      {
         var _loc6_:DisplayObject = null;
         var _loc7_:GuiItemSlot = null;
         super.initGuiBase(param1);
         this.activationCallback = param2;
         this.giveCallback = param3;
         this.removeCallback = param4;
         initContainer();
         this._button_item_left.guiButtonContext = param1;
         this._button_item_right.guiButtonContext = param1;
         this._button_item_left.setDownFunction(this.buttonLeftHandler);
         this._button_item_right.setDownFunction(this.buttonRightHandler);
         this.nav = new GuiGpNav(param1,"items",this);
         this.nav.alwaysHintControls = true;
         this.nav.setCallbackPress(this.navPressHandler);
         this.nav.setCallbackNavigate(this.navNavigateHandler);
         this.nav.setAlternateButton(GpControlButton.X,this.navAltHandler);
         this.nav.setAlignControlDefault(GuiGpAlignH.C,GuiGpAlignV.C);
         this.nav.setAlignNavDefault(GuiGpAlignH.C,GuiGpAlignV.S_UP);
         this.nav.pressOnNavigate = true;
         this.nav.scale = 1.5;
         var _loc5_:int = 0;
         while(_loc5_ < numChildren)
         {
            _loc6_ = getChildAt(_loc5_);
            _loc7_ = _loc6_ as GuiItemSlot;
            if(_loc7_)
            {
               _loc7_.init(param1);
               this.iconSlots.push(_loc7_);
               _loc7_.addEventListener(GuiIconSlotEvent.DRAG_START,this.iconSlotDragHandler);
               _loc7_.addEventListener(GuiIconSlotEvent.DRAG_END,this.iconSlotDragHandler);
               _loc7_.addEventListener(GuiIconSlotEvent.CLICKED,this.iconSlotClickHandler);
               this.nav.add(_loc7_);
               this.nav.setCaptionTokenControl(_loc7_,"pg_item_give");
               this.nav.setCaptionTokenAlt(_loc7_,"pg_item_remove");
            }
            _loc5_++;
         }
         this.theStage = stage;
         if(this.theStage)
         {
            this.theStage.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler,false,255);
         }
         this._info.init(param1);
         this.deactivateGp();
      }
      
      override public function set visible(param1:Boolean) : void
      {
         super.visible = param1;
         _context.translateDisplayObjects(LocaleCategory.GUI,this);
         this.handleLocaleChanged();
         if(!visible)
         {
            this.deactivateGp();
         }
      }
      
      public function handleLocaleChanged() : void
      {
         super.scaleTextfields();
         if(this._info)
         {
            this._info.handleLocaleChange();
         }
      }
      
      private function iconSlotClickHandler(param1:GuiIconSlotEvent) : void
      {
         var _loc2_:GuiItemSlot = param1.target as GuiItemSlot;
         this._info.itemDef = !!_loc2_.item ? _loc2_.item.def : null;
      }
      
      private function iconSlotDragHandler(param1:GuiIconSlotEvent) : void
      {
         var _loc2_:* = false;
         var _loc3_:GuiItemSlot = null;
         _loc2_ = GuiIconSlot.draggedSourceIconSlot == null;
         this._info.itemDef = null;
         for each(_loc3_ in this.iconSlots)
         {
            _loc3_.enabled = _loc2_;
            _loc3_.mouseEnabled = _loc2_;
            _loc3_.mouseChildren = _loc2_;
         }
      }
      
      public function cleanup() : void
      {
         var _loc1_:GuiItemSlot = null;
         this.activationCallback = null;
         this.giveCallback = null;
         this.removeCallback = null;
         this.deactivateGp();
         this.cmd_pg_items_left.cleanup();
         this.cmd_pg_items_right.cleanup();
         GuiGp.releasePrimaryBitmap(this.gp_l1);
         GuiGp.releasePrimaryBitmap(this.gp_r1);
         this._button_item_left.cleanup();
         this._button_item_right.cleanup();
         for each(_loc1_ in this.iconSlots)
         {
            _loc1_.cleanup();
            _loc1_.removeEventListener(GuiIconSlotEvent.DRAG_START,this.iconSlotDragHandler);
            _loc1_.removeEventListener(GuiIconSlotEvent.DRAG_END,this.iconSlotDragHandler);
            _loc1_.removeEventListener(GuiIconSlotEvent.CLICKED,this.iconSlotClickHandler);
         }
         this.clearAllIconSlots();
         this.iconSlots = null;
         if(this.theStage)
         {
            this.theStage.removeEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler,false);
            this.theStage = null;
         }
         if(this.nav)
         {
            this.nav.cleanup();
            this.nav = null;
         }
         super.cleanupGuiBase();
      }
      
      private function mouseDownHandler(param1:MouseEvent) : void
      {
         var _loc2_:GuiItemSlot = null;
         for each(_loc2_ in this.iconSlots)
         {
            if(_loc2_.visible)
            {
               if(_loc2_.hitTestPoint(param1.stageX,param1.stageY,true))
               {
                  return;
               }
            }
         }
         this._info.itemDef = null;
      }
      
      private function buttonLeftHandler(param1:ButtonWithIndex) : void
      {
         if(this.scrollIndex > 0)
         {
            --this.scrollIndex;
            this.updateVisibleIcons();
            this.updateScrollButtons();
         }
      }
      
      private function buttonRightHandler(param1:ButtonWithIndex) : void
      {
         if(this.scrollIndex < this.maxScrollIndex)
         {
            ++this.scrollIndex;
            this.updateVisibleIcons();
            this.updateScrollButtons();
         }
      }
      
      public function addIconEventListener(param1:String, param2:Function) : void
      {
         var _loc3_:GuiItemSlot = null;
         var _loc4_:EventDispatcher = null;
         for each(_loc3_ in this.iconSlots)
         {
            _loc4_ = _loc3_ as EventDispatcher;
            if(_loc4_)
            {
               _loc4_.addEventListener(param1,param2);
            }
         }
      }
      
      public function removeIconEventListener(param1:String, param2:Function) : void
      {
         var _loc3_:GuiItemSlot = null;
         var _loc4_:EventDispatcher = null;
         for each(_loc3_ in this.iconSlots)
         {
            _loc4_ = _loc3_ as EventDispatcher;
            if(_loc4_)
            {
               _loc4_.removeEventListener(param1,param2);
            }
         }
      }
      
      public function clearAllIconSlots() : void
      {
         var _loc1_:GuiItemSlot = null;
         for each(_loc1_ in this.iconSlots)
         {
            _loc1_.item = null;
         }
      }
      
      private function updateScrollButtons() : void
      {
         if(!this.items || !this.iconSlots)
         {
            return;
         }
         var _loc1_:* = this.items.length > this.iconSlots.length;
         this._button_item_left.visible = this._button_item_right.visible = _loc1_;
         this._button_item_left.enabled = this.scrollIndex > 0;
         this._button_item_right.enabled = this.scrollIndex < this.maxScrollIndex;
         if(this.gp_l1)
         {
            this.gp_l1.visible = this.isActivatedGp && this._button_item_left.visible && this._button_item_left.enabled;
         }
         if(this.gp_r1)
         {
            this.gp_r1.visible = this.isActivatedGp && this._button_item_right.visible && this._button_item_right.enabled;
         }
      }
      
      private function updateVisibleIcons() : void
      {
         var _loc1_:GuiItemSlot = null;
         var _loc2_:int = 0;
         var _loc4_:Item = null;
         if(!this.iconSlots || !this.items)
         {
            return;
         }
         var _loc3_:int = this.scrollIndex;
         while(_loc3_ < this.items.length && _loc2_ < this.iconSlots.length)
         {
            _loc1_ = this.iconSlots[_loc2_];
            _loc4_ = this.items[_loc3_];
            _loc1_.item = _loc4_;
            _loc1_.visible = true;
            if(!_loc4_ || _loc4_.def.rank > this.maxRank)
            {
               _loc1_.blockerVisible = true;
            }
            else
            {
               _loc1_.blockerVisible = !_loc4_ || Boolean(_loc4_.owner);
            }
            if(this._entity)
            {
               this.nav.setCaptionTokenControl(_loc1_,"pg_item_equip");
               this.nav.setShowControl(_loc1_,Boolean(_loc1_.item) && _loc1_.item.owner != this._entity);
               this.nav.setShowAlt(_loc1_,Boolean(_loc1_.item) && _loc1_.item.owner == this._entity);
            }
            else
            {
               this.nav.setCaptionTokenControl(_loc1_,"pg_item_give");
               this.nav.setShowControl(_loc1_,_loc1_.item != null);
               this.nav.setShowAlt(_loc1_,Boolean(_loc1_.item) && Boolean(_loc1_.item.owner));
            }
            _loc2_++;
            _loc3_++;
         }
         while(_loc2_ < this.iconSlots.length)
         {
            _loc1_ = this.iconSlots[_loc2_];
            _loc1_.item = null;
            _loc1_.visible = false;
            this.nav.setShowAlt(_loc1_,false);
            this.nav.setShowControl(_loc1_,false);
            _loc2_++;
         }
         this.updateGpItemDescription();
      }
      
      public function refreshGui() : void
      {
         var _loc1_:int = !!this.items ? int(this.items.length) : 0;
         var _loc2_:int = !!this.iconSlots ? int(this.iconSlots.length) : 0;
         this.maxScrollIndex = Math.max(0,_loc1_ - _loc2_);
         this.scrollIndex = Math.min(this.scrollIndex,this.maxScrollIndex);
         this._$items.visible = _loc1_ > 0;
         this.updateVisibleIcons();
         this.updateScrollButtons();
      }
      
      public function setItems(param1:Vector.<Item>, param2:int) : void
      {
         this.maxRank = param2;
         this.items = param1.concat();
         this.items.sort(this.itemDescendingComparator);
         this.clearAllIconSlots();
         this.refreshGui();
      }
      
      private function itemDescendingComparator(param1:Item, param2:Item) : int
      {
         if(param1.def.rank < param2.def.rank)
         {
            return 1;
         }
         if(param1.def.rank > param2.def.rank)
         {
            return -1;
         }
         return 0;
      }
      
      public function activateGp(param1:IEntityDef) : void
      {
         if(this.isActivatedGp)
         {
            return;
         }
         this._entity = param1;
         this.gplayer = GpBinder.gpbinder.createLayer("GuiItemSlots");
         this.nav.activate();
         this.gp_l1 = GpBinder.gpbinder.bindPress(GpControlButton.L1,this.cmd_pg_items_left,null,true).gpbmp;
         this.gp_r1 = GpBinder.gpbinder.bindPress(GpControlButton.R1,this.cmd_pg_items_right,null,true).gpbmp;
         this.gp_l1.alwaysHint = this.gp_r1.alwaysHint = true;
         this.gp_l1.scale = this.gp_r1.scale = 1.5;
         addChild(this.gp_l1);
         addChild(this.gp_r1);
         GuiGp.placeIcon(this._button_item_left,null,this.gp_l1,GuiGpAlignH.C,GuiGpAlignV.S);
         GuiGp.placeIcon(this._button_item_right,null,this.gp_r1,GuiGpAlignH.C,GuiGpAlignV.S);
         if(!this.nav.selected)
         {
            this.nav.autoSelect();
         }
         this.updateGpItemDescription();
         this.updateVisibleIcons();
         this.updateScrollButtons();
         if(this.activationCallback != null)
         {
            this.activationCallback();
         }
      }
      
      private function updateGpItemDescription() : void
      {
         var _loc1_:GuiItemSlot = null;
         if(this.isActivatedGp)
         {
            _loc1_ = this.nav.selected as GuiItemSlot;
            this._info.itemDef = Boolean(_loc1_) && Boolean(_loc1_.item) ? _loc1_.item.def : null;
         }
      }
      
      public function deactivateGp() : void
      {
         if(!this.isActivatedGp)
         {
            return;
         }
         GpBinder.gpbinder.unbind(this.cmd_pg_items_left);
         GpBinder.gpbinder.unbind(this.cmd_pg_items_right);
         GpBinder.gpbinder.removeLayer(this.gplayer);
         this.gplayer = 0;
         this.gp_l1 = null;
         this.gp_r1 = null;
         this.nav.deactivate();
         if(this._info)
         {
            this._info.itemDef = null;
         }
         if(this.activationCallback != null)
         {
            this.activationCallback();
         }
      }
      
      private function navNavigateHandler(param1:int, param2:int, param3:Boolean) : Boolean
      {
         if(param2 == 0 && param1 == 3)
         {
            this._button_item_left.press();
         }
         if(param2 == this.iconSlots.length - 1 && param1 == 1)
         {
            this._button_item_right.press();
         }
         return false;
      }
      
      private function navAltHandler(param1:DisplayObject) : void
      {
         if(this.removeCallback != null)
         {
            this.removeCallback(param1 as GuiItemSlot);
            this.updateVisibleIcons();
         }
      }
      
      private function navPressHandler(param1:DisplayObject, param2:Boolean) : Boolean
      {
         if(param2)
         {
            return false;
         }
         if(this.giveCallback != null)
         {
            if(this.giveCallback(param1 as GuiItemSlot))
            {
               return true;
            }
         }
         this.deactivateGp();
         return true;
      }
      
      private function cmdfunc_pg_items_left(param1:CmdExec) : void
      {
         this._button_item_left.press();
         if(this.gp_l1)
         {
            this.gp_l1.pulse();
         }
      }
      
      private function cmdfunc_pg_items_right(param1:CmdExec) : void
      {
         this._button_item_right.press();
         if(this.gp_r1)
         {
            this.gp_r1.pulse();
         }
      }
      
      public function get isActivatedGp() : Boolean
      {
         return this.gplayer != 0;
      }
   }
}

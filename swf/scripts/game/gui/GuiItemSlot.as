package game.gui
{
   import engine.entity.def.EntityIconType;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.Item;
   import flash.display.MovieClip;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   
   public class GuiItemSlot extends GuiIconSlot
   {
       
      
      public var _ownerHolder:MovieClip;
      
      private var _owner:IEntityDef;
      
      public var ownerIcon:GuiIcon;
      
      public var _item_bg:MovieClip;
      
      private var _item:Item;
      
      public var ownerEnabled:Boolean = true;
      
      public function GuiItemSlot()
      {
         super();
         this._ownerHolder = getChildByName("ownerHolder") as MovieClip;
         this._item_bg = getChildByName("item_bg") as MovieClip;
      }
      
      override public function cleanup() : void
      {
         this.item = null;
         super.cleanup();
      }
      
      override public function init(param1:IGuiContext) : void
      {
         super.init(param1);
         if(this._ownerHolder)
         {
            this._ownerHolder.visible = false;
         }
         this._item_bg.mouseEnabled = this._item_bg.mouseChildren = false;
      }
      
      private function get owner() : IEntityDef
      {
         return this._owner;
      }
      
      private function set owner(param1:IEntityDef) : void
      {
         if(this._owner == param1)
         {
            return;
         }
         if(this._owner)
         {
            if(this.ownerIcon)
            {
               this.ownerIcon.release();
               this._ownerHolder && this._ownerHolder.removeChild(this.ownerIcon);
               this.ownerIcon = null;
            }
         }
         this._owner = param1;
         this._setupOwnerIcon();
      }
      
      private function _setupOwnerIcon() : void
      {
         if(!this._ownerHolder)
         {
            return;
         }
         if(this._owner)
         {
            if(this.ownerEnabled)
            {
               this.ownerIcon = context.getIcon(this._owner.appearance.getIconUrl(EntityIconType.INIT_ORDER));
               this._ownerHolder.addChild(this.ownerIcon);
            }
         }
         if(this.ownerEnabled)
         {
            this._ownerHolder.visible = this.ownerIcon != null;
         }
         blockerVisible = this._ownerHolder.visible;
      }
      
      public function get item() : Item
      {
         return this._item;
      }
      
      private function itemOwnerHandler(param1:Event) : void
      {
         var _loc2_:Item = param1.target as Item;
         this.owner = _loc2_.owner;
      }
      
      public function set item(param1:Item) : void
      {
         if(this._item == param1)
         {
            return;
         }
         if(!_context)
         {
            throw new IllegalOperationError("need a context");
         }
         if(this._item)
         {
            this._item.removeEventListener(Item.EVENT_OWNER,this.itemOwnerHandler);
            icon = null;
            this.owner = null;
         }
         this._item = param1;
         if(this._item)
         {
            this._item.addEventListener(Item.EVENT_OWNER,this.itemOwnerHandler);
            icon = context.getIcon(this._item.def.icon);
            this.owner = this._item.owner;
            powerText = this._item.def.rank.toString();
         }
      }
   }
}

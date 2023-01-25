package engine.entity.def
{
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import engine.core.util.StringUtil;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class ItemListDef extends EventDispatcher
   {
       
      
      public var items:Vector.<ItemDef>;
      
      public var marketitems:Vector.<ItemDef>;
      
      private var itemsById:Dictionary;
      
      public var url:String;
      
      public var locale:Locale;
      
      public var logger:ILogger;
      
      public function ItemListDef(param1:Locale, param2:ILogger)
      {
         this.items = new Vector.<ItemDef>();
         this.marketitems = new Vector.<ItemDef>();
         this.itemsById = new Dictionary();
         super();
         this.locale = param1;
         this.logger = param2;
      }
      
      protected function addItemDef(param1:ItemDef) : void
      {
         if(this.getItemDef(param1.id))
         {
            throw new ArgumentError("ItemListDef.addItemDef already has item def: " + param1.id);
         }
         this.items.push(param1);
         this.itemsById[param1.id] = param1;
         if(!param1.omitFromMarketplace)
         {
            this.marketitems.push(param1);
         }
      }
      
      public function removeMarketItemsBelowRank(param1:int) : void
      {
         var _loc4_:ItemDef = null;
         var _loc5_:int = 0;
         var _loc2_:int = int(this.marketitems.length);
         var _loc3_:int = _loc2_ - 1;
         while(_loc3_ >= 0)
         {
            _loc4_ = this.marketitems[_loc3_];
            if(_loc4_.rank < param1)
            {
               this.marketitems[_loc3_] = this.marketitems[_loc2_ - 1];
               _loc2_--;
            }
            _loc3_--;
         }
         if(_loc2_ < this.marketitems.length)
         {
            _loc5_ = this.marketitems.length - _loc2_;
            this.logger.info("ItemListDef removed " + _loc5_ + " of " + this.marketitems.length + " items below rank " + param1);
            this.marketitems.splice(_loc2_,_loc5_);
         }
      }
      
      public function getItemDef(param1:String) : ItemDef
      {
         return this.itemsById[param1];
      }
      
      private function createItemDefLine(param1:ItemDef) : String
      {
         var _loc2_:* = StringUtil.padRight("[" + param1.id + "]"," ",21) + " ";
         var _loc3_:* = StringUtil.padRight(param1.createBrief(false,false)," ",36) + " ";
         var _loc4_:* = "[" + param1.icon + "]";
         return _loc2_ + _loc3_ + _loc4_;
      }
      
      private function td(param1:String) : String
      {
         return "<td>" + param1 + "</td>";
      }
      
      private function iconImg(param1:String) : String
      {
         var _loc2_:String = "http://stoicstudio.com/uploaded/item/" + StringUtil.getFilename(param1);
         return "<img width=\'61\' height=\'61\' src=\'" + _loc2_ + "\'/>";
      }
      
      private function createHtmlItemDefLine(param1:ItemDef) : String
      {
         return "<tr>" + this.td(this.iconImg(param1.icon)) + this.td(param1.rank.toString()) + this.td(param1.id) + this.td(param1.name) + this.td(param1.brief) + this.td(param1.description) + "</tr>\n";
      }
      
      private function createHtmlItemHeaderLine() : String
      {
         return "<tr>" + this.td("Icon") + this.td("Rank") + this.td("Id") + this.td("Name") + this.td("Brief") + this.td("Description") + "</tr>\n";
      }
      
      public function printItemDefs(param1:ILogger) : void
      {
         var _loc2_:ItemDef = null;
         param1.info("Purchasable Items: -----------------------------------------------------");
         for each(_loc2_ in this.items)
         {
            if(!_loc2_.omitFromMarketplace)
            {
               param1.info("    " + this.createItemDefLine(_loc2_));
            }
         }
         param1.info("Special/Unique Items: --------------------------------------------------");
         for each(_loc2_ in this.items)
         {
            if(_loc2_.omitFromMarketplace)
            {
               param1.info("    " + this.createItemDefLine(_loc2_));
            }
         }
      }
      
      public function makeItemDefsHtmlTable() : String
      {
         var _loc2_:ItemDef = null;
         var _loc1_:* = "<table>";
         _loc1_ += "<tr><td colspan=\'6\' style=\'border-bottom: 1px solid black;border-top: 1px solid black\'><h2>Purchasable Items</h2></td></tr>";
         _loc1_ += this.createHtmlItemHeaderLine();
         for each(_loc2_ in this.items)
         {
            if(!_loc2_.omitFromMarketplace)
            {
               _loc1_ += this.createHtmlItemDefLine(_loc2_);
            }
         }
         _loc1_ += "<tr><td colspan=\'6\' style=\'border-bottom: 1px solid black;border-top: 1px solid black\'><h2>Special/Unique Items</h2></td></tr>";
         _loc1_ += this.createHtmlItemHeaderLine();
         for each(_loc2_ in this.items)
         {
            if(_loc2_.omitFromMarketplace)
            {
               _loc1_ += this.createHtmlItemDefLine(_loc2_);
            }
         }
         return _loc1_ + "</table>";
      }
      
      public function cloneItemDef(param1:ItemDef) : ItemDef
      {
         var _loc3_:ItemDef = null;
         var _loc2_:String = this.getNewItemName(param1.id + "_");
         if(_loc2_)
         {
            _loc3_ = param1.clone();
            _loc3_.id = _loc2_;
            this.addItemDef(_loc3_);
            dispatchEvent(new ItemListDefEvent(ItemListDefEvent.EVENT_ADDED,_loc3_,this.items.length - 1));
            return _loc3_;
         }
         return null;
      }
      
      private function getNewItemName(param1:String) : String
      {
         var _loc3_:String = null;
         var _loc2_:int = 0;
         while(_loc2_ < 100)
         {
            _loc3_ = param1 + _loc2_;
            if(!this.getItemDef(_loc3_))
            {
               return _loc3_;
            }
            _loc2_++;
         }
         return null;
      }
      
      public function createItemDef() : ItemDef
      {
         var _loc2_:ItemDef = null;
         var _loc1_:String = this.getNewItemName("itm_new_");
         if(_loc1_)
         {
            _loc2_ = new ItemDef(this.locale);
            _loc2_.id = _loc1_;
            this.addItemDef(_loc2_);
            dispatchEvent(new ItemListDefEvent(ItemListDefEvent.EVENT_ADDED,_loc2_,this.items.length - 1));
            return _loc2_;
         }
         return null;
      }
      
      public function promoteItemDef(param1:ItemDef) : void
      {
         var _loc2_:int = this.items.indexOf(param1);
         if(_loc2_ > 0)
         {
            this.items.splice(_loc2_,1);
            this.items.splice(_loc2_ - 1,0,param1);
            dispatchEvent(new ItemListDefEvent(ItemListDefEvent.EVENT_PROMOTED,param1,_loc2_));
         }
      }
      
      public function demoteItemDef(param1:ItemDef) : void
      {
         var _loc2_:int = this.items.indexOf(param1);
         if(_loc2_ >= 0 && _loc2_ < this.items.length - 1)
         {
            this.items.splice(_loc2_,1);
            this.items.splice(_loc2_ + 1,0,param1);
            dispatchEvent(new ItemListDefEvent(ItemListDefEvent.EVENT_DEMOTED,param1,_loc2_));
         }
      }
      
      public function removeItemDef(param1:ItemDef) : void
      {
         var _loc2_:int = this.items.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.items.splice(_loc2_,1);
            dispatchEvent(new ItemListDefEvent(ItemListDefEvent.EVENT_REMOVED,param1,_loc2_));
         }
      }
      
      public function renameItemDef(param1:ItemDef, param2:String) : void
      {
         if(this.getItemDef(param2))
         {
            return;
         }
         var _loc3_:int = this.items.indexOf(param1);
         if(_loc3_ >= 0)
         {
            delete this.itemsById[param1.id];
            param1.id = param2;
            this.itemsById[param2] = param1;
            dispatchEvent(new ItemListDefEvent(ItemListDefEvent.EVENT_REID,param1,_loc3_));
         }
      }
      
      public function setItemDefOmitFromMarketplace(param1:ItemDef, param2:Boolean) : void
      {
         var _loc3_:int = 0;
         if(param1.omitFromMarketplace == param2)
         {
            return;
         }
         param1.omitFromMarketplace = param2;
         if(param2)
         {
            this.marketitems.push(param1);
         }
         else
         {
            _loc3_ = this.marketitems.indexOf(param1);
            if(_loc3_ >= 0)
            {
               this.marketitems.splice(_loc3_,1);
            }
         }
      }
      
      public function changeLocale(param1:Locale) : void
      {
         var _loc2_:ItemDef = null;
         for each(_loc2_ in this.items)
         {
            _loc2_.changeLocale(param1);
         }
      }
   }
}

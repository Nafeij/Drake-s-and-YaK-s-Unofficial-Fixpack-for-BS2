package engine.battle
{
   import flash.utils.Dictionary;
   
   public class SceneListDef
   {
       
      
      public var items:Vector.<SceneListItemDef>;
      
      private var _id2item:Dictionary;
      
      private var skus:Dictionary;
      
      public function SceneListDef()
      {
         this.items = new Vector.<SceneListItemDef>();
         this._id2item = new Dictionary();
         this.skus = new Dictionary();
         super();
      }
      
      public function fetch(param1:String) : SceneListItemDef
      {
         return this._id2item[param1];
      }
      
      protected function addItem(param1:SceneListItemDef) : void
      {
         if(param1.id in this._id2item)
         {
            throw new ArgumentError("Don\'t double-add");
         }
         this._id2item[param1.id] = param1;
         if(!param1.test)
         {
            this.items.push(param1);
         }
      }
      
      private function removeItem(param1:SceneListItemDef) : void
      {
         delete this._id2item[param1.id];
         var _loc2_:int = this.items.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.items.splice(_loc2_,1);
         }
      }
      
      public function mergeSku(param1:String, param2:SceneListDef) : void
      {
         var _loc3_:SceneListItemDef = null;
         this.purgeSku(param1);
         if(!param2)
         {
            return;
         }
         this.skus[param1] = param2;
         for each(_loc3_ in param2._id2item)
         {
            this.addItem(_loc3_);
         }
      }
      
      public function purgeSku(param1:String) : void
      {
         var _loc3_:SceneListItemDef = null;
         var _loc2_:SceneListDef = this.skus[param1];
         if(!_loc2_)
         {
            return;
         }
         delete this.skus[param1];
         for each(_loc3_ in _loc2_._id2item)
         {
            this.removeItem(_loc3_);
         }
      }
   }
}

package as3isolib.data
{
   import as3isolib.core.as3isolib_internal;
   import as3isolib.display.scene.IsoScene;
   
   public class Node implements INode
   {
      
      private static var _IDCount:uint = 0;
       
      
      private var _scene:IsoScene;
      
      public const UID:uint = _IDCount++;
      
      protected var setID:String;
      
      private var _internalId:String;
      
      private var _name:String;
      
      private var _data:Object;
      
      as3isolib_internal var ownerObject:Object;
      
      public var hasParent:Boolean;
      
      as3isolib_internal var parentNode:INode;
      
      as3isolib_internal var childrenArray:Array;
      
      public function Node()
      {
         this.as3isolib_internal::childrenArray = [];
         super();
         this._internalId = "node" + this.UID.toString();
      }
      
      public function notifySceneChildDirty() : void
      {
         if(this.scene)
         {
            this.scene.invalidateChild(this);
         }
      }
      
      public function get scene() : IsoScene
      {
         return this._scene;
      }
      
      public function set scene(param1:IsoScene) : void
      {
         this._scene = param1;
      }
      
      public function get id() : String
      {
         if(this.setID)
         {
            return this.setID;
         }
         return this._internalId;
      }
      
      public function set id(param1:String) : void
      {
         this.setID = param1;
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function set name(param1:String) : void
      {
         this._name = param1;
      }
      
      public function get data() : Object
      {
         return this._data;
      }
      
      public function set data(param1:Object) : void
      {
         this._data = param1;
      }
      
      public function get owner() : Object
      {
         return !!this.as3isolib_internal::ownerObject ? this.as3isolib_internal::ownerObject : this.as3isolib_internal::parentNode;
      }
      
      public function get parent() : INode
      {
         return this.as3isolib_internal::parentNode;
      }
      
      public function getRootNode() : INode
      {
         var _loc1_:Node = this;
         while(_loc1_.hasParent)
         {
            _loc1_ = _loc1_.parent as Node;
         }
         return _loc1_;
      }
      
      public function getDescendantNodes(param1:Boolean = false) : Array
      {
         var _loc3_:INode = null;
         var _loc2_:Array = [];
         for each(_loc3_ in this.as3isolib_internal::childrenArray)
         {
            if(_loc3_.children.length > 0)
            {
               _loc2_ = _loc2_.concat(_loc3_.getDescendantNodes(param1));
               if(param1)
               {
                  _loc2_.push(_loc3_);
               }
            }
            else
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
      
      public function contains(param1:INode) : Boolean
      {
         var _loc2_:INode = null;
         if((param1 as Node).hasParent)
         {
            return param1.parent == this;
         }
         for each(_loc2_ in this.as3isolib_internal::childrenArray)
         {
            if(_loc2_ == param1)
            {
               return true;
            }
         }
         return false;
      }
      
      public function get children() : Array
      {
         return this.as3isolib_internal::childrenArray;
      }
      
      public function get numChildren() : uint
      {
         return this.as3isolib_internal::childrenArray.length;
      }
      
      public function addChild(param1:INode) : void
      {
         this.addChildAt(param1,this.numChildren);
      }
      
      public function addChildAt(param1:INode, param2:uint) : void
      {
         var _loc3_:INode = null;
         if(this.getChildByID(param1.id))
         {
            return;
         }
         if((param1 as Node).hasParent)
         {
            _loc3_ = param1.parent;
            _loc3_.removeChildByID(param1.id);
         }
         Node(param1).as3isolib_internal::parentNode = this;
         Node(param1).hasParent = true;
         this.as3isolib_internal::childrenArray.splice(param2,0,param1);
      }
      
      public function getChildAt(param1:uint) : INode
      {
         if(param1 >= this.numChildren)
         {
            throw new Error("");
         }
         return INode(this.as3isolib_internal::childrenArray[param1]);
      }
      
      public function getChildIndex(param1:INode) : int
      {
         var _loc2_:int = 0;
         while(_loc2_ < this.numChildren)
         {
            if(param1 == this.as3isolib_internal::childrenArray[_loc2_])
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
      
      public function setChildIndex(param1:INode, param2:uint) : void
      {
         var _loc4_:INode = null;
         var _loc5_:Boolean = false;
         var _loc3_:int = this.getChildIndex(param1);
         if(_loc3_ == param2)
         {
            return;
         }
         if(_loc3_ > -1)
         {
            this.as3isolib_internal::childrenArray.splice(_loc3_,1);
            _loc5_ = false;
            for each(_loc4_ in this.as3isolib_internal::childrenArray)
            {
               if(_loc4_ == param1)
               {
                  _loc5_ = true;
               }
            }
            if(_loc5_)
            {
               throw new Error("");
            }
            if(param2 >= this.numChildren)
            {
               this.as3isolib_internal::childrenArray.push(param1);
            }
            else
            {
               this.as3isolib_internal::childrenArray.splice(param2,0,param1);
            }
            return;
         }
         throw new Error("");
      }
      
      public function removeChild(param1:INode) : INode
      {
         return this.removeChildByID(param1.id);
      }
      
      public function removeChildAt(param1:uint) : INode
      {
         var _loc2_:INode = null;
         if(param1 >= this.numChildren)
         {
            return null;
         }
         _loc2_ = INode(this.as3isolib_internal::childrenArray[param1]);
         return this.removeChildByID(_loc2_.id);
      }
      
      public function removeChildByID(param1:String) : INode
      {
         var _loc3_:uint = 0;
         var _loc2_:INode = this.getChildByID(param1);
         if(_loc2_)
         {
            Node(_loc2_).as3isolib_internal::parentNode = null;
            Node(_loc2_).hasParent = false;
            while(_loc3_ < this.as3isolib_internal::childrenArray.length)
            {
               if(_loc2_ == this.as3isolib_internal::childrenArray[_loc3_])
               {
                  this.as3isolib_internal::childrenArray.splice(_loc3_,1);
                  break;
               }
               _loc3_++;
            }
         }
         return _loc2_;
      }
      
      public function removeAllChildren() : void
      {
         var _loc1_:INode = null;
         for each(_loc1_ in this.as3isolib_internal::childrenArray)
         {
            Node(_loc1_).as3isolib_internal::parentNode = null;
            Node(_loc1_).hasParent = false;
         }
         this.as3isolib_internal::childrenArray.length = 0;
      }
      
      public function getChildByID(param1:String) : INode
      {
         var _loc2_:String = null;
         var _loc3_:INode = null;
         for each(_loc3_ in this.as3isolib_internal::childrenArray)
         {
            _loc2_ = _loc3_.id;
            if(_loc2_ == param1)
            {
               return _loc3_;
            }
         }
         return null;
      }
   }
}

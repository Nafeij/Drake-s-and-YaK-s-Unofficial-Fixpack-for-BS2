package as3isolib.data
{
   import as3isolib.display.scene.IsoScene;
   
   public interface INode
   {
       
      
      function notifySceneChildDirty() : void;
      
      function get scene() : IsoScene;
      
      function set scene(param1:IsoScene) : void;
      
      function get id() : String;
      
      function set id(param1:String) : void;
      
      function get name() : String;
      
      function set name(param1:String) : void;
      
      function get data() : Object;
      
      function set data(param1:Object) : void;
      
      function get owner() : Object;
      
      function get parent() : INode;
      
      function getRootNode() : INode;
      
      function getDescendantNodes(param1:Boolean = false) : Array;
      
      function contains(param1:INode) : Boolean;
      
      function get children() : Array;
      
      function get numChildren() : uint;
      
      function addChild(param1:INode) : void;
      
      function addChildAt(param1:INode, param2:uint) : void;
      
      function getChildIndex(param1:INode) : int;
      
      function getChildAt(param1:uint) : INode;
      
      function getChildByID(param1:String) : INode;
      
      function setChildIndex(param1:INode, param2:uint) : void;
      
      function removeChild(param1:INode) : INode;
      
      function removeChildAt(param1:uint) : INode;
      
      function removeChildByID(param1:String) : INode;
      
      function removeAllChildren() : void;
   }
}

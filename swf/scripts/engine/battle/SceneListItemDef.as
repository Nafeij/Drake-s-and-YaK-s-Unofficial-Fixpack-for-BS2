package engine.battle
{
   public class SceneListItemDef
   {
       
      
      public var id:String;
      
      public var sku:String;
      
      public var url:String;
      
      public var weight:Number;
      
      public var icon:String;
      
      public var test:Boolean;
      
      public var town:Boolean;
      
      public function SceneListItemDef()
      {
         super();
      }
      
      public function get token_name() : String
      {
         return "scene_" + this.id + "_name";
      }
      
      public function get token_desc() : String
      {
         return "scene_" + this.id + "_desc";
      }
   }
}

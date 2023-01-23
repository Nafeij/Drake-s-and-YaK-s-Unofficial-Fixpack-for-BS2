package engine.battle.board.view
{
   import as3isolib.display.IsoView;
   import as3isolib.display.scene.IsoScene;
   import flash.utils.Dictionary;
   
   public class IsoSceneLayers
   {
       
      
      protected var bg2:IsoScene;
      
      protected var bg1:IsoScene;
      
      protected var bg0:IsoScene;
      
      protected var main0:MainIsoScene;
      
      protected var fg0:IsoScene;
      
      private var isoView:IsoView;
      
      protected var id2IsoScene:Dictionary;
      
      public function IsoSceneLayers(param1:IsoView)
      {
         this.id2IsoScene = new Dictionary();
         super();
         this.bg2 = new IsoScene("bg2");
         this.bg1 = new IsoScene("bg1");
         this.bg0 = new IsoScene("bg0");
         this.main0 = new MainIsoScene();
         this.fg0 = new IsoScene("fg0");
         this.id2IsoScene["bg2"] = this.bg2;
         this.id2IsoScene["bg1"] = this.bg1;
         this.id2IsoScene["bg0"] = this.bg0;
         this.id2IsoScene["main0"] = this.main0;
         this.id2IsoScene["fg0"] = this.fg0;
         this.isoView = param1;
         param1.addScene(this.bg2);
         param1.addScene(this.bg1);
         param1.addScene(this.bg0);
         param1.addScene(this.main0);
         param1.addScene(this.fg0);
      }
      
      public function render() : void
      {
         this.bg2.render();
         this.bg1.render();
         this.bg0.render();
         this.main0.render();
         this.fg0.render();
      }
      
      public function cleanup() : void
      {
         var _loc1_:IsoScene = null;
         for each(_loc1_ in this.id2IsoScene)
         {
            this.isoView.removeScene(_loc1_);
            _loc1_.removeAllChildren();
         }
         this.id2IsoScene = null;
         this.isoView = null;
         this.bg2 = null;
         this.bg1 = null;
         this.bg0 = null;
         this.main0 = null;
         this.fg0 = null;
      }
      
      public function getIsoScene(param1:String) : IsoScene
      {
         return this.id2IsoScene[param1];
      }
   }
}

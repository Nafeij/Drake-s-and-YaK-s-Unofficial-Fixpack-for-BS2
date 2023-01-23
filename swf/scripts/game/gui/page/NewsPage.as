package game.gui.page
{
   import engine.session.NewsDef;
   import flash.events.Event;
   import game.cfg.GameConfig;
   import game.gui.GamePage;
   import game.view.GamePageManagerAdapter;
   
   public class NewsPage extends GamePage
   {
      
      public static var mcClazz:Class;
       
      
      private var gui:IGuiNews;
      
      private var _newsDef:NewsDef;
      
      private var _startIndex:int;
      
      public function NewsPage(param1:GameConfig)
      {
         super(param1);
      }
      
      public function get newsDef() : NewsDef
      {
         return this._newsDef;
      }
      
      public function setNews(param1:NewsDef, param2:int) : void
      {
         if(this._newsDef == param1)
         {
            return;
         }
         this._newsDef = param1;
         this._startIndex = param2;
         this.checkNews();
      }
      
      private function checkNews() : void
      {
         if(!this.gui || !this._newsDef)
         {
            return;
         }
         this.gui.showNews(this._newsDef,this._startIndex);
      }
      
      override public function cleanup() : void
      {
         this.gui = null;
         this._newsDef = null;
         super.cleanup();
      }
      
      override protected function handleStart() : void
      {
         if(mcClazz)
         {
            setFullPageMovieClipClass(mcClazz);
         }
      }
      
      override protected function handleLoaded() : void
      {
         if(fullScreenMc)
         {
            this.gui = fullScreenMc as IGuiNews;
            this.gui.init(config.gameGuiContext);
            this.gui.addEventListener(Event.CLOSE,this.guiCloseHandler);
            this.resizeHandler();
            this.checkNews();
         }
      }
      
      private function guiCloseHandler(param1:Event) : void
      {
         (manager as GamePageManagerAdapter).hideNews();
      }
      
      override protected function resizeHandler() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         super.resizeHandler();
         if(this.gui)
         {
            _loc1_ = 800;
            _loc2_ = 400;
         }
      }
   }
}

package as3isolib.display
{
   import as3isolib.display.renderers.IViewRenderer;
   import as3isolib.display.scene.IIsoScene;
   import as3isolib.geom.IsoMath;
   import as3isolib.geom.Pt;
   import as3isolib.utils.IsoUtil;
   import engine.landscape.view.DisplayObjectWrapper;
   import flash.geom.Point;
   import mx.core.IFactory;
   
   public class IsoView implements IIsoView
   {
       
      
      public var display:DisplayObjectWrapper;
      
      public var usePreciseValues:Boolean = false;
      
      public var autoUpdate:Boolean = false;
      
      private var viewRendererFactories:Array;
      
      protected var scenesArray:Array;
      
      private var _w:Number;
      
      private var _h:Number;
      
      private var _clipContent:Boolean = true;
      
      protected var mContainer:DisplayObjectWrapper;
      
      private var bgContainer:DisplayObjectWrapper;
      
      private var fgContainer:DisplayObjectWrapper;
      
      private var sceneContainer:DisplayObjectWrapper;
      
      public function IsoView(param1:String)
      {
         this.display = IsoUtil.createDisplayObjectWrapper();
         this.viewRendererFactories = [];
         this.scenesArray = [];
         super();
         this.display.name = param1;
         this.sceneContainer = IsoUtil.createDisplayObjectWrapper();
         this.sceneContainer.name = "scene";
         this.mContainer = IsoUtil.createDisplayObjectWrapper();
         this.mContainer.name = "container";
         this.mContainer.addChild(this.sceneContainer);
         this.display.addChild(this.mContainer);
         this.setSize(400,250);
      }
      
      public function localToIso(param1:Point) : Pt
      {
         param1 = this.display.localToGlobal(param1);
         param1 = this.mainContainer.globalToLocal(param1);
         return IsoMath.screenToIso(new Pt(param1.x,param1.y,0));
      }
      
      public function isoToLocal(param1:Pt) : Point
      {
         param1 = IsoMath.isoToScreen(param1);
         var _loc2_:Point = new Point(param1.x,param1.y);
         _loc2_ = this.mainContainer.localToGlobal(_loc2_);
         return this.display.globalToLocal(_loc2_);
      }
      
      public function getInvalidatedScenes() : Array
      {
         var _loc2_:IIsoScene = null;
         var _loc1_:Array = [];
         for each(_loc2_ in this.scenesArray)
         {
            if(_loc2_.isInvalidated)
            {
               _loc1_.push(_loc2_);
            }
         }
         return _loc1_;
      }
      
      public function render(param1:Boolean = false) : void
      {
         this.renderLogic(param1);
      }
      
      protected function renderLogic(param1:Boolean = false) : void
      {
         var _loc2_:IIsoScene = null;
         var _loc3_:IViewRenderer = null;
         var _loc4_:IFactory = null;
         if(param1)
         {
            for each(_loc2_ in this.scenesArray)
            {
               _loc2_.render(param1);
            }
         }
         if(Boolean(this.viewRenderers) && this.numScenes > 0)
         {
            for each(_loc4_ in this.viewRendererFactories)
            {
               _loc3_ = _loc4_.newInstance();
               _loc3_.renderView(this);
            }
         }
      }
      
      public function reset() : void
      {
         this.setSize(this._w,this._h);
         this.mContainer.x = 0;
         this.mContainer.y = 0;
      }
      
      public function get viewRenderers() : Array
      {
         return this.viewRendererFactories;
      }
      
      public function set viewRenderers(param1:Array) : void
      {
         var _loc2_:Array = null;
         var _loc3_:Object = null;
         if(param1)
         {
            _loc2_ = [];
            for each(_loc3_ in param1)
            {
               if(_loc3_ is IFactory)
               {
                  _loc2_.push(_loc3_);
               }
            }
            this.viewRendererFactories = _loc2_;
            if(this.autoUpdate)
            {
               this.render();
            }
         }
         else
         {
            this.viewRendererFactories = [];
         }
      }
      
      public function get scenes() : Array
      {
         return this.scenesArray;
      }
      
      public function get numScenes() : uint
      {
         return this.scenesArray.length;
      }
      
      public function addScene(param1:IIsoScene) : void
      {
         this.addSceneAt(param1,this.scenesArray.length);
      }
      
      public function addSceneAt(param1:IIsoScene, param2:int) : void
      {
         if(!this.containsScene(param1))
         {
            this.scenesArray.splice(param2,0,param1);
            param1.hostContainer = null;
            this.sceneContainer.addChildAt(param1.container,param2);
            return;
         }
         throw new Error("IsoView instance already contains parameter scene");
      }
      
      public function containsScene(param1:IIsoScene) : Boolean
      {
         var _loc2_:IIsoScene = null;
         for each(_loc2_ in this.scenesArray)
         {
            if(param1 == _loc2_)
            {
               return true;
            }
         }
         return false;
      }
      
      public function getSceneByID(param1:String) : IIsoScene
      {
         var _loc2_:IIsoScene = null;
         for each(_loc2_ in this.scenesArray)
         {
            if(_loc2_.id == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function removeScene(param1:IIsoScene) : IIsoScene
      {
         var _loc2_:int = 0;
         if(this.containsScene(param1))
         {
            _loc2_ = this.scenesArray.indexOf(param1);
            this.scenesArray.splice(_loc2_,1);
            this.sceneContainer.removeChild(param1.container);
            return param1;
         }
         return null;
      }
      
      public function removeAllScenes() : void
      {
         var _loc1_:IIsoScene = null;
         for each(_loc1_ in this.scenesArray)
         {
            if(this.sceneContainer.contains(_loc1_.container))
            {
               this.sceneContainer.removeChild(_loc1_.container);
               _loc1_.hostContainer = null;
            }
         }
         this.scenesArray = [];
      }
      
      public function get width() : Number
      {
         return this._w;
      }
      
      public function get height() : Number
      {
         return this._h;
      }
      
      public function get size() : Point
      {
         return new Point(this._w,this._h);
      }
      
      public function setSize(param1:Number, param2:Number) : void
      {
         this._w = Math.round(param1);
         this._h = Math.round(param2);
         this.mContainer.x = this._w / 2;
         this.mContainer.y = this._h / 2;
      }
      
      public function get clipContent() : Boolean
      {
         return this._clipContent;
      }
      
      public function set clipContent(param1:Boolean) : void
      {
         if(this._clipContent != param1)
         {
            this._clipContent = param1;
            this.reset();
         }
      }
      
      public function get mainContainer() : DisplayObjectWrapper
      {
         return this.mContainer;
      }
      
      public function get backgroundContainer() : DisplayObjectWrapper
      {
         if(!this.bgContainer)
         {
            this.bgContainer = IsoUtil.createDisplayObjectWrapper();
            this.mContainer.addChildAt(this.bgContainer,0);
         }
         return this.bgContainer;
      }
      
      public function get foregroundContainer() : DisplayObjectWrapper
      {
         if(!this.fgContainer)
         {
            this.fgContainer = IsoUtil.createDisplayObjectWrapper();
            this.mContainer.addChild(this.fgContainer);
         }
         return this.fgContainer;
      }
   }
}

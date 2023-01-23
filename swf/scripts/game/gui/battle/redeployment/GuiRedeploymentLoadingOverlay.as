package game.gui.battle.redeployment
{
   import engine.core.locale.LocaleCategory;
   import engine.gui.GuiContextEvent;
   import engine.gui.LoadingPips;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import flash.text.TextField;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   import game.gui.battle.IGuiLoadingOverlay;
   import game.gui.page.BattleHudPage;
   
   public class GuiRedeploymentLoadingOverlay extends GuiBase implements IGuiLoadingOverlay
   {
       
      
      private var _text$loading:TextField;
      
      private var _grayOverlay:MovieClip;
      
      private var _loadingPips:LoadingPips;
      
      private var bulbs:Vector.<DisplayObject>;
      
      public function GuiRedeploymentLoadingOverlay()
      {
         this.bulbs = new Vector.<DisplayObject>();
         super();
      }
      
      public function update(param1:int) : void
      {
         this._loadingPips.update(param1);
      }
      
      public function init(param1:IGuiContext, param2:BattleHudPage) : void
      {
         super.initGuiBase(param1);
         this._text$loading = requireGuiChild("text$loading") as TextField;
         registerScalableTextfieldAlign(this._text$loading);
         this._grayOverlay = requireGuiChild("gray_overlay") as MovieClip;
         var _loc3_:MovieClip = getChildByName("lits") as MovieClip;
         this._loadingPips = new LoadingPips(_loc3_);
         this.resizeHandler(param2.width,param2.height);
         _context.locale.translateDisplayObjects(LocaleCategory.GUI,this,param1.logger);
         _context.addEventListener(GuiContextEvent.LOCALE,this.localeHandler);
      }
      
      private function localeHandler(param1:GuiContextEvent) : void
      {
         this.updateTextfields();
      }
      
      private function updateTextfields() : void
      {
         _context.locale.fixTextFieldFormat(this._text$loading);
         scaleTextfields();
      }
      
      public function get displayObject() : DisplayObject
      {
         return this as DisplayObject;
      }
      
      override public function set visible(param1:Boolean) : void
      {
         if(super.visible != param1)
         {
            this._loadingPips.reset();
            super.visible = param1;
         }
      }
      
      public function cleanup() : void
      {
         _context.removeEventListener(GuiContextEvent.LOCALE,this.localeHandler);
         if(parent)
         {
            parent.removeChild(this);
         }
      }
      
      public function resizeHandler(param1:Number, param2:Number) : void
      {
         x = param1 / 2;
         y = param2 / 2;
         var _loc3_:Point = globalToLocal(new Point(0,0));
         this._grayOverlay.x = _loc3_.x;
         this._grayOverlay.y = _loc3_.y;
         this._grayOverlay.width = param1;
         this._grayOverlay.height = param2;
      }
   }
}

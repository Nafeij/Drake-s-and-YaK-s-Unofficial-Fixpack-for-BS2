package game.gui
{
   import engine.gui.GuiUtil;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   
   public class GuiTextCentered extends GuiBase
   {
       
      
      public var tf:TextField;
      
      public var tf_rect:Rectangle;
      
      public var my_rect:Rectangle;
      
      public function GuiTextCentered()
      {
         super();
         this.tf = requireGuiChild("text") as TextField;
         this.tf_rect = new Rectangle(0,0,this.tf.width,this.tf.height);
         this.tf.mouseEnabled = false;
         this.my_rect = new Rectangle(x,y,this.tf_rect.width,this.tf_rect.width);
      }
      
      public function init(param1:IGuiContext) : void
      {
         super.initGuiBase(param1);
      }
      
      public function resetPosition() : void
      {
         x = this.my_rect.x;
         y = this.my_rect.y;
      }
      
      public function setHtmlText(param1:String) : void
      {
         this.tf.htmlText = param1;
         _context.locale.fixTextFieldFormat(this.tf);
         GuiUtil.scaleTextToFitAlign(this.tf,"center",this.tf_rect);
         var _loc2_:Number = this.tf.textWidth * this.tf.scaleX;
         this.tf.x = (this.my_rect.width - _loc2_) / 2;
      }
   }
}

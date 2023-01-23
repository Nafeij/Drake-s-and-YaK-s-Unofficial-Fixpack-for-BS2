package game.gui.battle
{
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   import game.gui.IGuiDialog;
   
   public class GuiRenownConfirmDialog extends GuiBase
   {
       
      
      private var confirmColor:uint = 8759646;
      
      private var cancelColor:uint = 11624794;
      
      private var _confirmSound:String;
      
      private var _cancelSound:String;
      
      public function GuiRenownConfirmDialog()
      {
         super();
      }
      
      public function init(param1:IGuiContext) : void
      {
         initGuiBase(param1);
      }
      
      public function setSounds(param1:String, param2:String) : void
      {
         this._confirmSound = param1;
         this._cancelSound = param2;
      }
      
      public function display(param1:String, param2:String, param3:Function) : void
      {
         var cancel:String;
         var confirm:String = null;
         var titleId:String = param1;
         var body:String = param2;
         var callback:Function = param3;
         var dialog:IGuiDialog = context.createDialog();
         dialog.setColors(this.confirmColor,this.cancelColor);
         dialog.setSounds(this._confirmSound,this._cancelSound);
         confirm = context.translate("confirm");
         cancel = context.translate("cancel");
         dialog.openTwoBtnDialog(context.translate(titleId),body,confirm,cancel,function(param1:String):void
         {
            if(param1 == confirm)
            {
               callback("Confirm");
            }
            else
            {
               callback("Cancel");
            }
         });
      }
      
      public function cleanup() : void
      {
         super.cleanupGuiBase();
      }
   }
}

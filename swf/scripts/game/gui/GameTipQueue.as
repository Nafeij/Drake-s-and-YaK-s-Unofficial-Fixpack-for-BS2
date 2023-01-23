package game.gui
{
   import engine.saga.Saga;
   import engine.saga.vars.IVariable;
   import engine.saga.vars.VariableType;
   
   public class GameTipQueue
   {
       
      
      public var entries:Vector.<TipEntry>;
      
      private var context:IGuiContext;
      
      private var current:IGuiDialog;
      
      public function GameTipQueue(param1:IGuiContext)
      {
         this.entries = new Vector.<TipEntry>();
         super();
         this.context = param1;
      }
      
      public function hasShownTip(param1:Saga, param2:String) : Boolean
      {
         var _loc3_:IVariable = null;
         if(param1)
         {
            _loc3_ = param1.getVar(param2,VariableType.BOOLEAN);
            return Boolean(_loc3_) && _loc3_.asBoolean;
         }
         return false;
      }
      
      public function showTip(param1:Saga, param2:String, param3:String, param4:String) : void
      {
         var _loc5_:TipEntry = new TipEntry(param1,param2,param3,param4);
         this.entries.push(_loc5_);
         this.showNextTip();
      }
      
      private function showNextTip() : void
      {
         if(this.entries.length == 0)
         {
            return;
         }
         if(Boolean(this.current) && this.current == this.context.dialog)
         {
            return;
         }
         var _loc1_:TipEntry = this.entries[0];
         this.entries.splice(0,1);
         this.current = this.context.createDialog();
         var _loc2_:String = this.context.translate("ok");
         this.current.openDialog(_loc1_.title,_loc1_.body,_loc2_,this.dialogCloseHandler);
         _loc1_.saga.setVar(_loc1_.varname,true);
      }
      
      private function dialogCloseHandler(param1:String) : void
      {
         this.current = null;
         this.showNextTip();
      }
   }
}

import engine.saga.Saga;

class TipEntry
{
    
   
   public var saga:Saga;
   
   public var varname:String;
   
   public var title:String;
   
   public var body:String;
   
   public function TipEntry(param1:Saga, param2:String, param3:String, param4:String)
   {
      super();
      this.saga = param1;
      this.varname = param2;
      this.title = param3;
      this.body = param4;
   }
}

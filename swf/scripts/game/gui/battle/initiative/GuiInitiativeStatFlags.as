package game.gui.battle.initiative
{
   import com.greensock.TweenMax;
   import engine.entity.model.IEntity;
   import flash.display.Sprite;
   import game.gui.GuiBase;
   import game.gui.IGuiContext;
   
   public class GuiInitiativeStatFlags extends GuiBase
   {
      
      public static const SPEED:Number = 500;
       
      
      public var flags:Vector.<GuiInitiativeStatFlag>;
      
      public var _flagPlayer:GuiInitiativeStatFlag;
      
      public var _flagEnemy:GuiInitiativeStatFlag;
      
      private var _entity:IEntity;
      
      public var curFlag:GuiInitiativeStatFlag;
      
      private var startingParent:Sprite;
      
      private var outFlag:GuiInitiativeStatFlag;
      
      public function GuiInitiativeStatFlags()
      {
         this.flags = new Vector.<GuiInitiativeStatFlag>();
         super();
      }
      
      override public function handleLocaleChange() : void
      {
         var _loc1_:GuiInitiativeStatFlag = null;
         super.handleLocaleChange();
         if(this.flags)
         {
            for each(_loc1_ in this.flags)
            {
               _loc1_.handleLocaleChange();
            }
         }
      }
      
      public function init(param1:IGuiContext) : void
      {
         super.initGuiBase(param1);
         this.startingParent = parent as Sprite;
         this._flagPlayer = requireGuiChild("flagPlayer") as GuiInitiativeStatFlag;
         this._flagEnemy = requireGuiChild("flagEnemy") as GuiInitiativeStatFlag;
         this._flagPlayer.init(param1,param1.heraldry);
         this._flagEnemy.init(param1,null);
         this.mouseEnabled = true;
         this.mouseChildren = true;
         this.flags.push(this._flagPlayer);
         this.flags.push(this._flagEnemy);
         this._flagPlayer.visible = false;
         this._flagEnemy.visible = false;
      }
      
      public function updateDisplayLists() : void
      {
         var _loc1_:GuiInitiativeStatFlag = null;
         for each(_loc1_ in this.flags)
         {
         }
      }
      
      public function cleanup() : void
      {
         this._flagPlayer.cleanup();
         this._flagEnemy.cleanup();
         this.flags = null;
         super.cleanupGuiBase();
      }
      
      public function get entity() : IEntity
      {
         return this._entity;
      }
      
      public function set entity(param1:IEntity) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(this._entity == param1)
         {
            return;
         }
         if(this.curFlag)
         {
            if(this.outFlag && this.outFlag != this.curFlag && this.outFlag.visible)
            {
               this.outFlag.visible = false;
            }
            this.outFlag = this.curFlag;
            TweenMax.killTweensOf(this.curFlag);
            _loc2_ = (this.curFlag.height + y) / SPEED;
            TweenMax.to(this.curFlag,_loc2_,{
               "y":this.curFlag.height,
               "onComplete":this.tweenOutHandler
            });
            this.curFlag.entity = null;
            this.curFlag.deactivateTooltips();
         }
         this._entity = param1;
         if(this._entity)
         {
            if(this._entity.isEnemy)
            {
               this.curFlag = this._flagEnemy;
            }
            else
            {
               this.curFlag = this._flagPlayer;
            }
            if(this.curFlag)
            {
               this.curFlag.activateTooltips();
               if(this.curFlag == this.outFlag)
               {
                  this.outFlag = null;
               }
               this.curFlag.y = this.curFlag.height;
               TweenMax.killTweensOf(this.curFlag);
               _loc3_ = (this.curFlag.height + y) / SPEED;
               TweenMax.to(this.curFlag,_loc3_,{"y":0});
               this.curFlag.entity = this._entity;
               this.curFlag.visible = true;
               setChildIndex(this.curFlag,1);
            }
         }
      }
      
      private function tweenOutHandler() : void
      {
         if(this.outFlag)
         {
            this.outFlag.visible = false;
         }
      }
      
      public function handleOptionsShowing(param1:Boolean) : void
      {
         if(this.curFlag)
         {
            if(param1 || !this._entity || !visible)
            {
               this.curFlag.deactivateTooltips();
            }
            else
            {
               this.curFlag.activateTooltips();
            }
         }
      }
   }
}

package game.cfg
{
   import engine.entity.def.IEntityDef;
   
   public class LobbyMemberInfo
   {
       
      
      public var id:int;
      
      public var display_name:String;
      
      public var joined:Boolean;
      
      public var ready:Boolean;
      
      public var party:Vector.<IEntityDef>;
      
      public var location:String;
      
      public function LobbyMemberInfo(param1:int, param2:String)
      {
         this.party = new Vector.<IEntityDef>();
         super();
         this.id = param1;
         this.display_name = param2;
      }
   }
}

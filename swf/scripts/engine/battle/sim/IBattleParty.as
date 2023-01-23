package engine.battle.sim
{
   import engine.battle.board.model.BattlePartyType;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import flash.events.IEventDispatcher;
   import flash.geom.Point;
   
   public interface IBattleParty extends IEventDispatcher
   {
       
      
      function get numMembers() : int;
      
      function get numActive() : int;
      
      function getAliveMember(param1:int) : IBattleEntity;
      
      function getMember(param1:int) : IBattleEntity;
      
      function getMemberByDefId(param1:String) : IBattleEntity;
      
      function getMemberById(param1:String) : IBattleEntity;
      
      function getMemberByIdOrDefId(param1:String) : IBattleEntity;
      
      function getMemberIndex(param1:IBattleEntity) : int;
      
      function get board() : IBattleBoard;
      
      function get id() : String;
      
      function get team() : String;
      
      function get deployment() : String;
      
      function get deployed() : Boolean;
      
      function set deployed(param1:Boolean) : void;
      
      function get type() : BattlePartyType;
      
      function get isPlayer() : Boolean;
      
      function get isEnemy() : Boolean;
      
      function get isAlly() : Boolean;
      
      function get surrendered() : Boolean;
      
      function set surrendered(param1:Boolean) : void;
      
      function get aborted() : Boolean;
      
      function set aborted(param1:Boolean) : void;
      
      function get partyName() : String;
      
      function get artifactChargeCount() : int;
      
      function set artifactChargeCount(param1:int) : void;
      
      function getAllMembers(param1:Vector.<IBattleEntity>) : Vector.<IBattleEntity>;
      
      function getDeadMembers(param1:Vector.<IBattleEntity>) : Vector.<IBattleEntity>;
      
      function get timer() : int;
      
      function get numAlive() : int;
      
      function get trauma() : Number;
      
      function get vitality() : Number;
      
      function get initialVitality() : Number;
      
      function get bonusRenown() : int;
      
      function set bonusRenown(param1:int) : void;
      
      function getCentroid() : Point;
      
      function toString() : String;
      
      function get rankMin() : int;
      
      function get rankMax() : int;
      
      function undeployAll() : void;
      
      function visit(param1:Function) : void;
      
      function changeDeployment(param1:String) : void;
      
      function getDebugString() : String;
      
      function movePartyMember(param1:IBattleEntity, param2:int) : void;
      
      function removeMember(param1:IBattleEntity) : void;
   }
}

unit Test.PureMVC.Patterns.Facade;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit
  being tested.

}

interface

uses
  TestFramework,
  PureMVC.Patterns.Facade,
  PureMVC.Interfaces.IFacade;

type
  // Test methods for class TFacade

  TestTFacade = class(TTestCase)
  strict private
  public
  published
    procedure TestGetInstance;
    procedure TestRegisterCommandAndNotifyObservers;
    procedure TestRegisterAndRemoveCommandAndSendNotification;
    procedure TestRegisterAndRetrieveProxy;
    procedure TestRegisterAndRemoveProxy;
    procedure TestRegisterRetrieveAndRemoveMediator;
    procedure TestHasProxy;
    procedure TestHasMediator;
    procedure TestHasCommand;
  end;

implementation

uses
  RTTI,
  PureMVC.Patterns.Command,
  PureMVC.Patterns.Mediator,
  PureMVC.Patterns.Proxy,
  PureMVC.Interfaces.INotification,
  PureMVC.Interfaces.IProxy,
  PureMVC.Interfaces.IMediator,
  SysUtils;

type
  TFacadeTestVO = class
  private
    FInput: Integer;
    FResult: Integer;
  public
    constructor Create(Input: Integer);
    property Input: Integer read FInput;
    property Result: Integer read FResult write FResult;
  end;

  TFacadeTestCommand = class(TSimpleCommand)
  public
    procedure Execute(Note: INotification); override;
  end;

  { TFacadeTestVO }

constructor TFacadeTestVO.Create(Input: Integer);
begin
  inherited Create;
  FInput := Input;
end;

{ TFacadeTestCommand }

procedure TFacadeTestCommand.Execute(Note: INotification);
var
  VO: TFacadeTestVO;
begin
  VO := (Note.Sender as TFacadeTestVO);
  VO.Result := 2 * VO.Input;
end;

{ TestTFacade }

procedure TestTFacade.TestGetInstance;
var
  Facade: IFacade;
begin
  Facade := TFacade.Instance;
  CheckNotNull(Facade, 'Expecting instance not null');
  CheckTrue(Supports(Facade, IFacade), 'Expecting instance implements IFacade');
end;

procedure TestTFacade.TestRegisterCommandAndNotifyObservers;
var
  Facade: IFacade;
  VO: TFacadeTestVO;

begin
  Facade := TFacade.Instance;
  Facade.RegisterCommand('FacadeTestNote', TFacadeTestCommand);

  // Send notification. The Command associated with the event
  // (FacadeTestCommand) will be invoked, and will multiply
  // the VO.input value by 2 and set the result on vo.result
  VO := TFacadeTestVO.Create(32);
  try
    Facade.SendNotification('FacadeTestNote', VO);
    CheckEquals(64, VO.Result);
  finally
    VO.Free;
  end;
end;

{ **
  * Tests Command removal via the Facade.
  *
  * <P>
  * This test gets the Singleton Facade instance
  * and registers the FacadeTestCommand class
  * to handle 'FacadeTest' Notifcations. Then it removes the command.<P>
  *
  * <P>
  * It then sends a Notification using the Facade.
  * Success is determined by evaluating
  * a property on an object placed in the body of
  * the Notification, which will NOT be modified by the Command.</P>
  *
  * }

procedure TestTFacade.TestRegisterAndRemoveCommandAndSendNotification;
var
  Facade: IFacade;
  VO: TFacadeTestVO;

begin
  Facade := TFacade.Instance;
  Facade.RegisterCommand('FacadeTestNote', TFacadeTestCommand);
  Facade.RemoveCommand('FacadeTestNote');
  // Send notification. The Command associated with the event
  // (FacadeTestCommand) will NOT be invoked, and will NOT multiply
  // the vo.input value by 2
  VO := TFacadeTestVO.Create(32);
  try
    Facade.SendNotification('FacadeTestNote', VO);
    CheckEquals(0, VO.Result);
  finally
    VO.Free;
  end;
end;

{ **
  * Tests the regsitering and retrieving Model proxys via the Facade.
  *
  * <P>
  * Tests <code>registerModelProxy</code> and <code>retrieveModelProxy</code> in the same test.
  * These methods cannot currently be tested separately
  * in any meaningful way other than to show that the
  * methods do not throw exception when called. </P>
  * }
procedure TestTFacade.TestRegisterAndRetrieveProxy;
var
  Facade: IFacade;
  Data: TArray<string>;
  Proxy: IProxy;
begin
  Facade := TFacade.Instance;
  Facade.RegisterProxy(TProxy.Create('colors', TValue.FromArray(TypeInfo(TArray<string>), ['red', 'green', 'blue'])));
  Proxy := Facade.RetrieveProxy('colors');

  // test assertions
  CheckTrue(Supports(Proxy, IProxy), 'Expecting proxy implements IProxy');

  // retrieve data from proxy
  Data := Proxy.Data.AsType<TArray<string>>;
  CheckEquals(3, Length(Data));
  CheckEquals('red', Data[0]);
  CheckEquals('green', Data[1]);
  CheckEquals('blue', Data[2]);
  Facade.RemoveProxy('colors');
end;

procedure TestTFacade.TestRegisterAndRemoveProxy;
var
  Facade: IFacade;
  RemovedProxy: IProxy;
  Proxy: IProxy;
begin
  Facade := TFacade.Instance;
  Facade.RegisterProxy(TProxy.Create('sizes', TValue.FromArray(TypeInfo(TArray<Integer>), [7, 13, 21])));
  RemovedProxy := Facade.RemoveProxy('sizes');
  CheckEquals('sizes', RemovedProxy.ProxyName);
  Proxy := Facade.RetrieveProxy('sizes');
  CheckNull(Proxy, 'Expecting proxy is null');
end;

procedure TestTFacade.TestRegisterRetrieveAndRemoveMediator;
var
  Facade: IFacade;
  RemovedMediator: IMediator;
begin
  Facade := TFacade.Instance;
  Facade.RegisterMediator(TMediator.Create('Mediator', Self));

  CheckNotNull(Facade.RetrieveMediator('Mediator'), 'Expecting mediator is not null');

  // remove the mediator
  RemovedMediator := facade.RemoveMediator('Mediator');

  // assert that we have removed the appropriate mediator
  CheckEquals('Mediator', RemovedMediator.MediatorName);
  CheckNull(Facade.RetrieveMediator('Mediator'), 'Expecting mediator is  null');
end;

procedure TestTFacade.TestHasProxy;
var
  Facade: IFacade;
begin
  Facade := TFacade.Instance;
  Facade.RegisterProxy(TProxy.Create('hasProxyTest', TValue.FromArray(TypeInfo(TArray<Integer>), [1, 2, 3])));
  CheckTrue(Facade.HasProxy('hasProxyTest'));
  Facade.RemoveProxy('hasProxyTest');
end;


procedure TestTFacade.TestHasMediator;
var
  Facade: IFacade;
begin
  Facade := TFacade.Instance;
  Facade.RegisterMediator(TMediator.Create('facadeHasMediatorTest', Self));
  CheckTrue(Facade.HasMediator('facadeHasMediatorTest'));
  Facade.RemoveMediator('facadeHasMediatorTest');
  CheckFalse(Facade.HasMediator('facadeHasMediatorTest'));
end;

procedure TestTFacade.TestHasCommand;
var
  Facade: IFacade;
begin
  Facade := TFacade.Instance;

  Facade.RegisterCommand('facadeHasCommandTest', TFacadeTestCommand);
  CheckTrue(Facade.HasCommand('facadeHasCommandTest'));

  Facade.RemoveCommand('facadeHasCommandTest');
  CheckFalse(Facade.HasCommand('facadeHasCommandTest'));
end;

initialization

// Register any test cases with the test runner
RegisterTest(TestTFacade.Suite);

end.

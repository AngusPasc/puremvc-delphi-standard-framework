unit PureMVC.Interfaces.IProxy;

interface

type

  /// <summary>
  /// The interface definition for a PureMVC Proxy
  /// </summary>
  /// <remarks>
  /// <para>In PureMVC, <c>IProxy</c> implementors assume these responsibilities:</para>
  /// <list type="bullet">
  /// <item>Implement a common method which returns the name of the Proxy</item>
  /// </list>
  /// <para>Additionally, <c>IProxy</c>s typically:</para>
  /// <list type="bullet">
  /// <item>Maintain references to one or more pieces of model data</item>
  /// <item>Provide methods for manipulating that data</item>
  /// <item>Generate <c>INotifications</c> when their model data changes</item>
  /// <item>Expose their name as a <c>public static const</c> called <c>NAME</c></item>
  /// <item>Encapsulate interaction with local or remote services used to fetch and persist model data</item>
  /// </list>
  /// </remarks>

  IProxy = interface
    /// <summary>
    /// The Proxy instance name
    /// </summary>
    function GetProxyName: string;
    property ProxyName: string read GetProxyName;

    /// <summary>
    /// The data of the proxy
    /// </summary>
    function GetData: TObject;
    procedure SetData(Value: TObject);
    property Data: TObject read GetData write SetData;

    /// <summary>
    /// Called by the Model when the Proxy is registered
    /// </summary>
    procedure OnRegister();

    /// <summary>
    /// Called by the Model when the Proxy is removed
    /// </summary>
    procedure OnRemove();
  end;

implementation

end.

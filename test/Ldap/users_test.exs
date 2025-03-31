defmodule Iface.Ldap.UsersTest do
  use ExUnit.Case
  alias Iface.Ldap.Users
  import Mock

  setup do
    # Esperar 1 segundo (1000 ms) entre cada test
    Process.sleep(1000)
    :ok
  end

  # doctest Iface.Ldap.Users, except: [user_create: 5]

  @data [
    %{
      "cn" => ["jcbatman"],
      "description" => ["jcbatman"],
      "dn" => ["uid=jcbatman,ou=Users"],
      "eboxDigestPassword" => ["{MD5}mCoHMX+6+UeQmKGWi6IVSQ=="],
      "eboxLmPassword" => ["115A114CB4E7DE8037B24AE41CB61727"],
      "eboxMd5Password" => ["{MD5}p9fzKsHGcqSBHZoO4Jys5A=="],
      "eboxNtPassword" => ["7C2B29DAB1D48A693A1D08052C4F1B7A"],
      "eboxRealmPassword" => ["{MD5}982a07317fbaf9479098a1968ba21549"],
      "eboxSha1Password" => ["{SHA}7kHNhLw9+861X9RIjuwKpytp8V8="],
      "gidNumber" => ["1901"],
      "givenName" => ["Juan Carlos"],
      "hasMoodleAccess" => ["TRUE"],
      "homeDirectory" => ["/home/jcbatman"],
      "loginShell" => ["/usr/sbin/nologin"],
      "mail" => ["jcbatman@policia.rionegro.gov.ar"],
      "mailHomeDirectory" => ["/var/vmail/"],
      "mailbox" => ["policia.rionegro.gov.ar/jcbatman/"],
      "objectClass" => [
        "inetOrgPerson",
        "posixAccount",
        "passwordHolder",
        "CourierMailAccount",
        "usereboxmail",
        "fetchmailUser",
        "policeOrgPerson",
        "top"
      ],
      "quota" => ["230"],
      "sn" => ["Batman"],
      "uid" => ["jcbatman"],
      "uidNumber" => ["2002"],
      "userMaildirSize" => ["0"],
      "userPassword" => ["{SSHA}7mKA9i9nFd++2cmzqG+tzCJbmRKm6IC5"]
    },
    %{
      "sambaPrimaryGroupSID" => ["S-1-5-21-2536628940-703160423-1994053749-513"],
      "mail" => ["jsrobin@policia.rionegro.gov.ar"],
      "mailHomeDirectory" => ["/var/vmail/"],
      "uid" => ["jsrobin"],
      "mailbox" => ["policia.rionegro.gov.ar/jsrobin/"],
      "sambaPwdMustChange" => ["2147483647"],
      "uidNumber" => ["21534"],
      "sambaKickoffTime" => ["2147483647"],
      "eboxNtPassword" => ["A7E207024D46BD32BB8C1405F4F1C06A"],
      "dn" => ["uid=jsrobin,ou=Users"],
      "userPassword" => ["{SSHA}yrTEjaS0OJzj5o0DubGiOqC/4eoA8j1o"],
      "sambaAcctFlags" => ["[U          ]"],
      "eboxDigestPassword" => ["{MD5}IXpeTCun8Db7ybkwQSkahA=="],
      "sambaNTPassword" => ["6D85D270479B8CCCCC648C4FE864D4BB"],
      "sambaDomainName" => ["POLICIA"],
      "eboxRealmPassword" => ["{MD5}217a5e4c2ba7f036fbc9b93041291a84"],
      "sambaPwdCanChange" => ["2147483647"],
      "description" => ["11501"],
      "userMaildirSize" => ["0"],
      "homeDirectory" => ["/home/jsrobin"],
      "objectClass" => [
        "inetOrgPerson",
        "posixAccount",
        "passwordHolder",
        "CourierMailAccount",
        "usereboxmail",
        "fetchmailUser",
        "policeOrgPerson",
        "top",
        "sambaSamAccount"
      ],
      "eboxSha1Password" => ["{SHA}ik46CmHk93thDJlLECu+Ehe8rDM="],
      "loginShell" => ["/usr/sbin/nologin"],
      "eboxLmPassword" => ["D5700123FDD7632287604B2BBA074692"],
      "quota" => ["230"],
      "sambaPasswordHistory" => [
        "00000000000000000000000000000000000000000000000000000000000000000"
      ],
      "sn" => ["Robin"],
      "givenName" => ["Jose Maria"],
      "gidNumber" => ["1901"],
      "sambaPwdLastSet" => ["1503048361"],
      "hasMoodleAccess" => ["FALSE"],
      "sambaSID" => ["S-1-5-21-2536628940-703160423-1994053749-44068"],
      "eboxMd5Password" => ["{MD5}v2sKFCVtpH6Pwt1NMyd6tQ=="],
      "cn" => ["Robin, Jose Maria"]
    }
  ]

  test_with_mock "La funcion user_get_all/2 debe retornar todos los usuarios", Paddle,
    get: fn base: [ou: "Users"] -> {:ok, @data} end,
    authenticate: fn _, _ -> :ok end do
    assert Users.user_get_all(Paddle) ==
             {:ok,
              [
                %{
                  "cn" => "jcbatman",
                  "description" => "jcbatman",
                  "dn" => "uid=jcbatman,ou=Users",
                  "eboxDigestPassword" => "{MD5}mCoHMX+6+UeQmKGWi6IVSQ==",
                  "eboxLmPassword" => "115A114CB4E7DE8037B24AE41CB61727",
                  "eboxMd5Password" => "{MD5}p9fzKsHGcqSBHZoO4Jys5A==",
                  "eboxNtPassword" => "7C2B29DAB1D48A693A1D08052C4F1B7A",
                  "eboxRealmPassword" => "{MD5}982a07317fbaf9479098a1968ba21549",
                  "eboxSha1Password" => "{SHA}7kHNhLw9+861X9RIjuwKpytp8V8=",
                  "gidNumber" => "1901",
                  "givenName" => "Juan Carlos",
                  "hasMoodleAccess" => "TRUE",
                  "homeDirectory" => "/home/jcbatman",
                  "loginShell" => "/usr/sbin/nologin",
                  "mail" => "jcbatman@policia.rionegro.gov.ar",
                  "mailHomeDirectory" => "/var/vmail/",
                  "mailbox" => "policia.rionegro.gov.ar/jcbatman/",
                  "objectClass" => [
                    "inetOrgPerson",
                    "posixAccount",
                    "passwordHolder",
                    "CourierMailAccount",
                    "usereboxmail",
                    "fetchmailUser",
                    "policeOrgPerson",
                    "top"
                  ],
                  "quota" => "230",
                  "sn" => "Batman",
                  "uid" => "jcbatman",
                  "uidNumber" => "2002",
                  "userMaildirSize" => "0",
                  "userPassword" => "{SSHA}7mKA9i9nFd++2cmzqG+tzCJbmRKm6IC5"
                },
                %{
                  "cn" => "Robin, Jose Maria",
                  "description" => "11501",
                  "dn" => "uid=jsrobin,ou=Users",
                  "eboxDigestPassword" => "{MD5}IXpeTCun8Db7ybkwQSkahA==",
                  "eboxLmPassword" => "D5700123FDD7632287604B2BBA074692",
                  "eboxMd5Password" => "{MD5}v2sKFCVtpH6Pwt1NMyd6tQ==",
                  "eboxNtPassword" => "A7E207024D46BD32BB8C1405F4F1C06A",
                  "eboxRealmPassword" => "{MD5}217a5e4c2ba7f036fbc9b93041291a84",
                  "eboxSha1Password" => "{SHA}ik46CmHk93thDJlLECu+Ehe8rDM=",
                  "gidNumber" => "1901",
                  "givenName" => "Jose Maria",
                  "hasMoodleAccess" => "FALSE",
                  "homeDirectory" => "/home/jsrobin",
                  "loginShell" => "/usr/sbin/nologin",
                  "mail" => "jsrobin@policia.rionegro.gov.ar",
                  "mailHomeDirectory" => "/var/vmail/",
                  "mailbox" => "policia.rionegro.gov.ar/jsrobin/",
                  "objectClass" => [
                    "inetOrgPerson",
                    "posixAccount",
                    "passwordHolder",
                    "CourierMailAccount",
                    "usereboxmail",
                    "fetchmailUser",
                    "policeOrgPerson",
                    "top",
                    "sambaSamAccount"
                  ],
                  "quota" => "230",
                  "sambaAcctFlags" => "[U          ]",
                  "sambaDomainName" => "POLICIA",
                  "sambaKickoffTime" => "2147483647",
                  "sambaNTPassword" => "6D85D270479B8CCCCC648C4FE864D4BB",
                  "sambaPasswordHistory" =>
                    "00000000000000000000000000000000000000000000000000000000000000000",
                  "sambaPrimaryGroupSID" => "S-1-5-21-2536628940-703160423-1994053749-513",
                  "sambaPwdCanChange" => "2147483647",
                  "sambaPwdLastSet" => "1503048361",
                  "sambaPwdMustChange" => "2147483647",
                  "sambaSID" => "S-1-5-21-2536628940-703160423-1994053749-44068",
                  "sn" => "Robin",
                  "uid" => "jsrobin",
                  "uidNumber" => "21534",
                  "userMaildirSize" => "0",
                  "userPassword" => "{SSHA}yrTEjaS0OJzj5o0DubGiOqC/4eoA8j1o"
                }
              ]}
  end

  test_with_mock "La funcion user_get_all/2 debe retornar una lista vacia si no hay usuarios",
                 Paddle,
                 get: fn base: [ou: "Users"] -> {:ok, []} end,
                 authenticate: fn _, _ -> :ok end do
    assert Users.user_get_all(Paddle) == {:ok, []}
  end

  test_with_mock "El ultimo uid obtenido por la funcion user_get_all/2 debe ser 21534", Paddle,
    get: fn base: [ou: "Users"] -> {:ok, @data} end,
    authenticate: fn _, _ -> :ok end do
    assert Users.user_last_uid(false, Paddle) == {:ok, 21_534}
  end

  test_with_mock "El ultimo uid obtenido por la funcion user_get_all/2 +1 debe ser 21535", Paddle,
    get: fn base: [ou: "Users"] -> {:ok, @data} end,
    authenticate: fn _, _ -> :ok end do
    assert Users.user_last_uid(Paddle) == {:ok, 21_535}
  end

  test_with_mock "La funcion user_exist?/2 debe retornar true si el usuario existe", Paddle,
    get: fn base: [ou: "Users"] -> {:ok, @data} end,
    authenticate: fn _, _ -> :ok end do
    assert Users.user_exists?("jsrobin", Paddle) == true
  end

  test_with_mock "La funcion user_exist?/2 debe retornar false si el usuario no existe", Paddle,
    get: fn base: [ou: "Users"] -> {:ok, @data} end,
    authenticate: fn _, _ -> :ok end do
    assert Users.user_exists?("jocker", Paddle) == false
  end

  test_with_mock "La funcion user_info/2 obtiene informacion de usuario, los valores no son listas",
                 Paddle,
                 get: fn base: [ou: "Users"], filter: [uid: "jcbatman"] ->
                   {:ok, @data}
                 end,
                 authenticate: fn _, _ -> :ok end do
    assert Users.user_info("jcbatman", Paddle) ==
             {:ok,
              %{
                "cn" => "jcbatman",
                "description" => "jcbatman",
                "dn" => "uid=jcbatman,ou=Users",
                "eboxDigestPassword" => "{MD5}mCoHMX+6+UeQmKGWi6IVSQ==",
                "eboxLmPassword" => "115A114CB4E7DE8037B24AE41CB61727",
                "eboxMd5Password" => "{MD5}p9fzKsHGcqSBHZoO4Jys5A==",
                "eboxNtPassword" => "7C2B29DAB1D48A693A1D08052C4F1B7A",
                "eboxRealmPassword" => "{MD5}982a07317fbaf9479098a1968ba21549",
                "eboxSha1Password" => "{SHA}7kHNhLw9+861X9RIjuwKpytp8V8=",
                "gidNumber" => "1901",
                "givenName" => "Juan Carlos",
                "hasMoodleAccess" => "TRUE",
                "homeDirectory" => "/home/jcbatman",
                "loginShell" => "/usr/sbin/nologin",
                "mail" => "jcbatman@policia.rionegro.gov.ar",
                "mailHomeDirectory" => "/var/vmail/",
                "mailbox" => "policia.rionegro.gov.ar/jcbatman/",
                "objectClass" => [
                  "inetOrgPerson",
                  "posixAccount",
                  "passwordHolder",
                  "CourierMailAccount",
                  "usereboxmail",
                  "fetchmailUser",
                  "policeOrgPerson",
                  "top"
                ],
                "quota" => "230",
                "sn" => "Batman",
                "uid" => "jcbatman",
                "uidNumber" => "2002",
                "userMaildirSize" => "0",
                "userPassword" => "{SSHA}7mKA9i9nFd++2cmzqG+tzCJbmRKm6IC5"
              }}
  end

  test_with_mock "La funcion user_create/5 debe crear un nuevo usuario completo con todos los atributos",
                 Paddle,
                 get: fn base: [ou: "Users"] -> {:ok, @data} end,
                 authenticate: fn _, _ -> :ok end,
                 add: fn [uid: "jcbatman", ou: "Users"], new_user ->
                   data = [new_user | @data]
                   {:ok, Enum.count(data), Map.delete(new_user, :userPassword)}
                 end do
    {status, count, created_user} =
      Users.user_create("jcbatman", "123456", "Juan Carlos", "Batman", Paddle)

    assert status == :ok

    assert count == 3

    assert created_user == %{
             cn: "Juan Carlos Batman",
             mailbox: "jcbatman@policia.rionegro.gov.ar",
             gecos: "Juan Carlos Batman",
             gidNumber: 1901,
             givenName: "Juan Carlos",
             hasMoodleAccess: "FALSE",
             homeDirectory: "/var/vmail",
             loginShell: "/bin/bash",
             objectclass: [
               "top",
               "policeOrgPerson",
               "posixAccount",
               "inetOrgPerson",
               "organizationalPerson",
               "person",
               "passwordHolder",
               "CourierMailAccount",
               "fetchmailUser",
               "usereboxmail",
               "shadowAccount",
               "sambaSamAccount"
             ],
             sn: "Batman",
             uidNumber: 21535,
             mail: "jcbatman@policia.rionegro.gov.ar",
             shadowExpire: "-1",
             shadowFlag: "0",
             shadowMax: "999999",
             shadowMin: "8",
             shadowWarning: "7",
             sambaAcctFlags: "[U          ]",
             sambaDomainName: "POLICIA",
             sambaKickoffTime: "2147483647",
             sambaNTPassword: "32ED87BDB5FDC5E9CBA88547376818D4",
             sambaPasswordHistory:
               "00000000000000000000000000000000000000000000000000000000000000000",
             sambaPrimaryGroupSID: "S-1-5-21-2536628940-703160423-1994053749-513",
             sambaPwdCanChange: "2147483647",
             sambaPwdLastSet: "2147483647",
             sambaPwdMustChange: "2147483647",
             sambaSID: "S-1-5-21-2536628940-703160423-1994053749-21535",
             mailHomeDirectory: "/home/jcbatman",
             quota: 230,
             userMailDirSize: 1
           }
  end

  test_with_mock "La funcion user_create/6 debe crear un nuevo usuario con objectClass email y sus atributos",
                 Paddle,
                 get: fn base: [ou: "Users"] -> {:ok, @data} end,
                 authenticate: fn _, _ -> :ok end,
                 add: fn [uid: "jcbatman", ou: "Users"], new_user ->
                   data = [new_user | @data]
                   {:ok, Enum.count(data), Map.delete(new_user, :userPassword)}
                 end do
    {status, count, created_user} =
      Users.user_create("jcbatman", "123456", "Juan Carlos", "Batman", Paddle, [:mail])

    assert status == :ok

    assert count == 3

    assert created_user == %{
             cn: "Juan Carlos Batman",
             gidNumber: 1901,
             mail: "jcbatman@policia.rionegro.gov.ar",
             objectclass: [
               "top",
               "policeOrgPerson",
               "posixAccount",
               "inetOrgPerson",
               "organizationalPerson",
               "person",
               "passwordHolder",
               "CourierMailAccount",
               "fetchmailUser",
               "usereboxmail"
             ],
             uidNumber: 21535,
             sn: "Batman",
             givenName: "Juan Carlos",
             gecos: "Juan Carlos Batman",
             loginShell: "/bin/bash",
             hasMoodleAccess: "FALSE",
             homeDirectory: "/var/vmail",
             quota: 230,
             mailbox: "jcbatman@policia.rionegro.gov.ar",
             mailHomeDirectory: "/home/jcbatman",
             userMailDirSize: 1
           }
  end

  # ! TODO: Cambiar a test_with_mock
  describe "user_create/5 y user_create/6" do
    test "Debe crear un nuevo usuario con objectClass shadow y sus atributos" do
      {status, count, created_user} =
        Users.user_create("jcbatman", "123456", "Juan Carlos", "Batman", MockLdapClient, [:shadow])

      assert status == :ok

      assert count == 3

      assert created_user == %{
               cn: "Juan Carlos Batman",
               gidNumber: 1901,
               objectclass: [
                 "top",
                 "policeOrgPerson",
                 "posixAccount",
                 "inetOrgPerson",
                 "organizationalPerson",
                 "person",
                 "passwordHolder",
                 "shadowAccount"
               ],
               uidNumber: 21535,
               sn: "Batman",
               givenName: "Juan Carlos",
               gecos: "Juan Carlos Batman",
               loginShell: "/bin/bash",
               hasMoodleAccess: "FALSE",
               homeDirectory: "/var/vmail",
               shadowFlag: "0",
               shadowExpire: "-1",
               shadowMax: "999999",
               shadowMin: "8",
               shadowWarning: "7"
             }
    end

    test "Debe crear un nuevo usuario con objectClass samba y sus atributos" do
      {status, count, created_user} =
        Users.user_create("jcbatman", "123456", "Juan Carlos", "Batman", MockLdapClient, [:samba])

      assert status == :ok

      assert count == 3

      assert created_user == %{
               cn: "Juan Carlos Batman",
               gidNumber: 1901,
               sambaSID: "S-1-5-21-2536628940-703160423-1994053749-21535",
               objectclass: [
                 "top",
                 "policeOrgPerson",
                 "posixAccount",
                 "inetOrgPerson",
                 "organizationalPerson",
                 "person",
                 "passwordHolder",
                 "sambaSamAccount"
               ],
               uidNumber: 21535,
               sn: "Batman",
               givenName: "Juan Carlos",
               gecos: "Juan Carlos Batman",
               loginShell: "/bin/bash",
               hasMoodleAccess: "FALSE",
               homeDirectory: "/var/vmail",
               sambaDomainName: "POLICIA",
               sambaNTPassword: "32ED87BDB5FDC5E9CBA88547376818D4",
               sambaAcctFlags: "[U          ]",
               sambaPasswordHistory:
                 "00000000000000000000000000000000000000000000000000000000000000000",
               sambaPrimaryGroupSID: "S-1-5-21-2536628940-703160423-1994053749-513",
               sambaKickoffTime: "2147483647",
               sambaPwdCanChange: "2147483647",
               sambaPwdMustChange: "2147483647",
               sambaPwdLastSet: "2147483647"
             }
    end

    test "Debe crear un nuevo usuario con objectClass samba, shadow y sus atributos" do
      {status, count, created_user} =
        Users.user_create("jcbatman", "123456", "Juan Carlos", "Batman", MockLdapClient, [
          :samba,
          :shadow
        ])

      assert status == :ok

      assert count == 3

      assert created_user == %{
               cn: "Juan Carlos Batman",
               gidNumber: 1901,
               sambaSID: "S-1-5-21-2536628940-703160423-1994053749-21535",
               objectclass: [
                 "top",
                 "policeOrgPerson",
                 "posixAccount",
                 "inetOrgPerson",
                 "organizationalPerson",
                 "person",
                 "passwordHolder",
                 "shadowAccount",
                 "sambaSamAccount"
               ],
               uidNumber: 21535,
               sn: "Batman",
               givenName: "Juan Carlos",
               gecos: "Juan Carlos Batman",
               loginShell: "/bin/bash",
               hasMoodleAccess: "FALSE",
               homeDirectory: "/var/vmail",
               sambaDomainName: "POLICIA",
               sambaNTPassword: "32ED87BDB5FDC5E9CBA88547376818D4",
               sambaAcctFlags: "[U          ]",
               sambaPasswordHistory:
                 "00000000000000000000000000000000000000000000000000000000000000000",
               sambaPrimaryGroupSID: "S-1-5-21-2536628940-703160423-1994053749-513",
               sambaKickoffTime: "2147483647",
               sambaPwdCanChange: "2147483647",
               sambaPwdMustChange: "2147483647",
               sambaPwdLastSet: "2147483647",
               shadowFlag: "0",
               shadowExpire: "-1",
               shadowMax: "999999",
               shadowMin: "8",
               shadowWarning: "7"
             }
    end

    test "Debe crear un nuevo usuario con objectClass samba, email y sus atributos" do
      {status, count, created_user} =
        Users.user_create("jcbatman", "123456", "Juan Carlos", "Batman", MockLdapClient, [
          :samba,
          :mail
        ])

      assert status == :ok

      assert count == 3

      assert created_user == %{
               cn: "Juan Carlos Batman",
               gidNumber: 1901,
               sambaSID: "S-1-5-21-2536628940-703160423-1994053749-21535",
               mail: "jcbatman@policia.rionegro.gov.ar",
               objectclass: [
                 "top",
                 "policeOrgPerson",
                 "posixAccount",
                 "inetOrgPerson",
                 "organizationalPerson",
                 "person",
                 "passwordHolder",
                 "CourierMailAccount",
                 "fetchmailUser",
                 "usereboxmail",
                 "sambaSamAccount"
               ],
               uidNumber: 21535,
               sn: "Batman",
               givenName: "Juan Carlos",
               gecos: "Juan Carlos Batman",
               loginShell: "/bin/bash",
               hasMoodleAccess: "FALSE",
               homeDirectory: "/var/vmail",
               quota: 230,
               mailbox: "jcbatman@policia.rionegro.gov.ar",
               mailHomeDirectory: "/home/jcbatman",
               userMailDirSize: 1,
               sambaDomainName: "POLICIA",
               sambaNTPassword: "32ED87BDB5FDC5E9CBA88547376818D4",
               sambaAcctFlags: "[U          ]",
               sambaPasswordHistory:
                 "00000000000000000000000000000000000000000000000000000000000000000",
               sambaPrimaryGroupSID: "S-1-5-21-2536628940-703160423-1994053749-513",
               sambaKickoffTime: "2147483647",
               sambaPwdCanChange: "2147483647",
               sambaPwdMustChange: "2147483647",
               sambaPwdLastSet: "2147483647"
             }
    end

    test "Debe crear un nuevo usuario con objectClass mail, shadow y sus atributos" do
      {status, count, created_user} =
        Users.user_create("jcbatman", "123456", "Juan Carlos", "Batman", MockLdapClient, [
          :mail,
          :shadow
        ])

      assert status == :ok

      assert count == 3

      assert created_user == %{
               cn: "Juan Carlos Batman",
               gidNumber: 1901,
               mail: "jcbatman@policia.rionegro.gov.ar",
               objectclass: [
                 "top",
                 "policeOrgPerson",
                 "posixAccount",
                 "inetOrgPerson",
                 "organizationalPerson",
                 "person",
                 "passwordHolder",
                 "shadowAccount",
                 "CourierMailAccount",
                 "fetchmailUser",
                 "usereboxmail"
               ],
               uidNumber: 21535,
               sn: "Batman",
               givenName: "Juan Carlos",
               gecos: "Juan Carlos Batman",
               loginShell: "/bin/bash",
               hasMoodleAccess: "FALSE",
               homeDirectory: "/var/vmail",
               quota: 230,
               mailbox: "jcbatman@policia.rionegro.gov.ar",
               mailHomeDirectory: "/home/jcbatman",
               userMailDirSize: 1,
               shadowFlag: "0",
               shadowExpire: "-1",
               shadowMax: "999999",
               shadowMin: "8",
               shadowWarning: "7"
             }
    end
  end
end

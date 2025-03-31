defmodule Iface.Ldap.UsersTest do
  use ExUnit.Case
  alias Iface.Ldap.Users

  doctest Iface.Ldap.Users, except: [user_create: 5]

  # Mock de ldap_client (Paddle) para tests.
  defmodule MockLdapClient do
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

    def authenticate(_, _), do: :ok
    def get(base: [ou: "Users"]), do: {:ok, @data}
    def get(base: [ou: "Users"], filter: [uid: "jcbatman"]), do: {:ok, @data}
  end

  describe "user_last_uid/2" do
    test "El ultimo uid debe ser 21534" do
      assert Users.user_last_uid(false, MockLdapClient) == 21_534
    end

    test "El ultimo uid +1 debe ser 21535" do
      assert Users.user_last_uid(MockLdapClient) == 21_535
    end
  end

  describe "user_exists/2" do
    test "El usario jcbatman exite" do
      assert Users.user_exists?("jcbatman", MockLdapClient) == true
    end

    test "El usario jocker no exite" do
      assert Users.user_exists?("jocker", MockLdapClient) == false
    end
  end

  describe "user_info/2" do
    test "user_info/2 no tiene listas en valores de un solo elemento" do
      assert Users.user_info("jcbatman", MockLdapClient) ==
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
  end
end

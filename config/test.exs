import Config

config :seqy,
  topics: [
    %{
      name: :user_purchase,
      actions: [:"user.created", :"user.purchased", :"user.paid"],
      handler: Seqy.Support.FakeHandler
    }
  ]

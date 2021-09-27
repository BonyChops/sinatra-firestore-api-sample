require 'sinatra'
require 'sinatra/namespace'
require 'json'
require 'google/cloud/firestore'

use Rack::MethodOverride
project_id = ENV['FIRESTORE_PROJECT']
firestore = Google::Cloud::Firestore.new project_id: project_id
set :environment, :production

def error_obj(mes)
  JSON.pretty_generate({ mes: mes, status: 'error' })
end

def check_params(params, required_params)
  required_params.each do |param|
    return false if params[param].nil?
  end
  true
end

# Namespace: api．'/db'だと'/api/db'でアクセスできる
namespace '/api' do
  get '/' do
    params = {
      'status' => 'ok',
      'mesage' => 'Hello World!'
    }
    body JSON.pretty_generate(params)
  end

  # コレクションusersの中身をJSONで返すエンドポイント
  get '/db' do
    collection_path = 'users'
    users_ref = firestore.col collection_path
    result = {}
    users_ref.get do |city|
      puts "#{city.document_id} data: #{city.data}."
      result[city.document_id] = city.data
    end

    body JSON.pretty_generate(result)
  end

  # コレクションusersに新しいドキュメント(レコード)を追加するエンドポイント
  post '/db' do
    # 足りないパラメータがあったらエラーを返す
    unless check_params(params, %w[name age])
      status 400
      body error_obj('Not enough params')
      return
    end

    # コレクション名
    collection_path = 'users'
    # リファレンス
    users_ref = firestore.col collection_path
    id = [*'A'..'Z', *'a'..'z', *0..9].sample(8).join
    # データ挿入
    users_ref.doc(id).set(
      {
        id: id,
        name: params[:name],
        age: params[:age]
      }
    )
    body JSON.pretty_generate({ status: 'ok' })
  end
end

not_found do
  params = {
    'status' => 'error',
    'message' => 'Not Found.'
  }
  status 404
  erb JSON.pretty_generate(params)
end

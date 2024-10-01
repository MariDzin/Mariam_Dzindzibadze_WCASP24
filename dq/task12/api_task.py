import boto3
import pytest
from botocore import UNSIGNED
from botocore.config import Config
from google.cloud import storage


@pytest.fixture(scope='function')
def provide_config():
    config = {
        'prefix': '2022/01/01/KTLX/',  # Updated date
        'gcp_bucket_name': "gcp-public-data-nexrad-l2",
        'aws_bucket_name': 'noaa-nexrad-level2',
        's3_anon_client': boto3.client('s3', config=Config(signature_version=UNSIGNED)),
        'gcp_storage_anon_client': storage.Client.create_anonymous_client()
    }
    return config


@pytest.fixture(scope='function')
def list_gcs_blobs(provide_config):
    config = provide_config
    blobs = config['gcp_storage_anon_client'].list_blobs(
        config['gcp_bucket_name'], prefix=config['prefix'])
    objects = [blob.name for blob in blobs]
    return objects


@pytest.fixture(scope='function')
def list_aws_blobs(provide_config):
    config = provide_config
    paginator = config['s3_anon_client'].get_paginator('list_objects_v2')
    page_iterator = paginator.paginate(
        Bucket=config['aws_bucket_name'], Prefix=config['prefix'])
    objects = []
    for page in page_iterator:
        if 'Contents' in page:
            objects.extend([content['Key'] for content in page['Contents']])
    return objects


@pytest.fixture(scope='function')
def provide_posts_data():
    posts_data = [
        {
            "userId": 3,
            "id": 21,
            "title": "asperiores ea ipsam voluptatibus modi minima quia sint",
            "body": "repellat aliquid praesentium dolorem quo"
                    "\nsed totam minus non itaque\nnihil labore molestiae sunt dolor eveniet hic recusandae veniam"
                    "\ntempora et tenetur expedita sunt"
        },
        {
            "userId": 3,
            "id": 22,
            "title": "dolor sint quo a velit explicabo quia nam",
            "body": "eos qui et ipsum ipsam suscipit aut"
                    "\nsed omnis non odio\nexpedita earum mollitia molestiae aut atque rem suscipit"
                    "\nnam impedit esse"
        },
        {
            "userId": 3,
            "id": 23,
            "title": "maxime id vitae nihil numquam",
            "body": "veritatis unde neque eligendi"
                    "\nquae quod architecto quo neque vitae"
                    "\nest illo sit tempora doloremque fugit quod"
                    "\net et vel beatae sequi ullam sed tenetur perspiciatis"
        },
        {
            "userId": 3,
            "id": 24,
            "title": "autem hic labore sunt dolores incidunt",
            "body": "enim et ex nulla"
                    "\nomnis voluptas quia qui"
                    "\nvoluptatem consequatur numquam aliquam sunt"
                    "\ntotam recusandae id dignissimos aut sed asperiores deserunt"
        },
        {
            "userId": 3,
            "id": 25,
            "title": "rem alias distinctio quo quis",
            "body": "ullam consequatur ut"
                    "\nomnis quis sit vel consequuntur"
                    "\nipsa eligendi ipsum molestiae et omnis error nostrum"
                    "\nmolestiae illo tempore quia et distinctio"
        },
        {
            "userId": 3,
            "id": 26,
            "title": "est et quae odit qui non",
            "body": "similique esse doloribus nihil accusamus"
                    "\nomnis dolorem fuga consequuntur reprehenderit fugit recusandae temporibus"
                    "\nperspiciatis cum ut laudantium\nomnis aut molestiae vel vero"
        },
        {
            "userId": 3,
            "id": 27,
            "title": "quasi id et eos tenetur aut quo autem",
            "body": "eum sed dolores ipsam sint possimus debitis occaecati"
                    "\ndebitis qui qui et"
                    "\nut placeat enim earum aut odit facilis"
                    "\nconsequatur suscipit necessitatibus rerum sed inventore temporibus consequatur"
        },
        {
            "userId": 3,
            "id": 28,
            "title": "delectus ullam et corporis nulla voluptas sequi",
            "body": "non et quaerat ex quae ad maiores"
                    "\nmaiores recusandae totam aut blanditiis mollitia quas illo"
                    "\nut voluptatibus voluptatem\nsimilique nostrum eum"
        },
        {
            "userId": 3,
            "id": 29,
            "title": "iusto eius quod necessitatibus culpa ea",
            "body": "odit magnam ut saepe sed non qui"
                    "\ntempora atque nihil"
                    "\naccusamus illum doloribus illo dolor"
                    "\neligendi repudiandae odit magni similique sed cum maiores"
        },
        {
            "userId": 3,
            "id": 30,
            "title": "a quo magni similique perferendis",
            "body": "alias dolor cumque"
                    "\nimpedit blanditiis non eveniet odio maxime"
                    "\nblanditiis amet eius quis tempora quia autem rem"
                    "\na provident perspiciatis quia"
        }
    ]
    return posts_data


def test_user_with_posts(provide_posts_data):
    """
    Verify that 10 posts were created for user with userId=3.
    """
    posts = provide_posts_data
    user_posts = [post for post in posts if post['userId'] == 3]
    assert len(user_posts) == 10, f"Expected 10 posts for userId=3, got {len(user_posts)}"


def test_data_is_present_in_gcp_bucket(list_gcs_blobs):
    """
    Verify that the GCP bucket for the specified date is not empty.
    """
    gcs_objects = list_gcs_blobs
    assert len(gcs_objects) > 0, "GCP bucket is empty for the specified date"


def test_data_is_present_in_aws_bucket(list_aws_blobs):
    """
    Verify that the AWS bucket for the specified date is not empty.
    """
    aws_objects = list_aws_blobs
    assert len(aws_objects) > 0, "AWS bucket is empty for the specified date"
